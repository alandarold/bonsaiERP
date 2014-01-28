module Models::History

  def self.included(base)
    base.send(:extend, InstanceMethods)
    base.instance_eval do
      before_save :create_history
      has_many :histories, -> { order('histories.created_at desc, id desc') }, as: :historiable, dependent: :destroy
      delegate :details_col, :state_col, :due_date_col, to: self
    end

  end

  module InstanceMethods

    def history_with_details(details_col)
      @details_col = details_col
    end

    def history_state_date(state_col = :state, due_date_col = :due_date)
      @state_col, @due_date_col = state_col, due_date_col
    end

    # No need for mattr_reader or mattr_accessor not recomended use of
    # @@var class variables
    [:details_col, :state_col, :due_date_col].each do |meth|
      define_method meth do
        instance_variable_get(:"@#{meth}")
      end
    end
  end

  private

    def create_history
      if new_record?
        h = store_new_record
      else
        h = store_update
      end

      h.save
    end

    def store_new_record
      histories.build(new_item: true, user_id: history_user_id, history_data: {})
    end

    def store_update
      h = get_data
      set_details(h)  if details_col.present?
      set_state_col(h)  if state_col.present?

      histories.build(new_item: false, history_data: h, user_id: history_user_id)
    end

    def set_details(h)
      det_hash = get_details
      h[details_col] = det_hash  unless det_hash.empty?
    end

    def get_details
      send(details_col).each_with_index.map do |det, i|
        if det.new_record?
          { new_record: true, index: i }
        elsif changed_detail?(det)
          get_data(det).merge(id: det.id)
        elsif det.marked_for_destruction?
          { destroyed: true, index: i }.merge(det.attributes)
        else
          nil
        end
      end.compact
    end

    def set_state_col(h)
      unless h[state_col].present?
        today = Date.today
        if today > send(:"#{due_date_col}_was")
          h[state_col] = { from: 'due', to: send(state_col), type: 'string' }
        end
      end
    end

    def get_data(object = self)
      Hash[ get_object_attributes(object).map { |k, v|
        [k, { from: v, to: object.send(k), type: object.class.column_types[k].type } ]
      }]
    end

    def history_user_id
      UserSession.id
    end

    def get_object_attributes(object)
      object.changed_attributes.except('created_at', 'updated_at')
    end

    def changed_detail?(det)
      det.changed_attributes.except('created_at', 'updated_at').any?
    end
end
