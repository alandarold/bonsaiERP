# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryPresenter < BasePresenter

  def link
    case
    when(is_income? || is_expense?)
      "/inventories/#{id}/show_movement"
    when is_trans?
      "/inventories/#{id}/show_trans"
    else
      to_model
    end
  end

  def operation_tag
    case operation
    when "in" then label_green(operation_name)
    when "out" then label_red(operation_name)
    when "inc_out" then label_green(operation_name)
    when "inc_in" then label_red(operation_name)
    when "exp_in" then label_green(operation_name)
    when "exp_out" then label_red(operation_name)
    when "trans" then label_black(operation_name)
    end
  end

  def operation_name
    case operation
    when "in" then "Ingreso"
    when "out" then "Salida"
    when "inc_out" then "Entrega"
    when "inc_in" then "Devolución"
    when "exp_in" then "Recepción"
    when "exp_out" then "Devolución"
    when "trans" then "Transferencia"
    end
  end

  def select_store_title
    case
    when (transaction.is_a?(Income) and inventory_operation.out?)
      "<span class='dark_green'>Entrega</span>".html_safe
    when (transaction.is_a?(Income) and inventory_operation.in?)
      "<span class='red'>Devolución</span>".html_safe
    when (transaction.is_a?(Buy) and inventory_operation.in?)
      "<span class='dark_green'>Recojo</span>".html_safe
    when (transaction.is_a?(Buy) and inventory_operation.out?)
      "<span class='red'>Devolución</span>".html_safe
    end
  end

  def related
    case
    when is_income?  then income
    when is_expense? then expense
    when store_to_id.present? then store_to
    else
      nil
    end
  end

  def related_tag
    case
    when is_income?
      text_tag_green("Ingreso:")
    when is_expense?
      text_tag_red("Egreso:")
    end
  end

  def related_tip
    case
    when is_income?
      "Ingreso"
    when is_expense?
      "Egreso"
    when is_trans?
      "Almacen"
    end
  end

  def transaction_title
    "#{select_store_title} #{transaction}".html_safe
  end

  def title
    store = h.link_to inventory_operation.store, store_path(inventory_operation.store_id, :tab => 'operations'), :class => 'n'

    case
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Income) && inventory_operation.out? )
      "<span class='gray n'>Entrega</span> #{store} - #{transaction}".html_safe
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Income) && inventory_operation.in? )
      "<span class='gray n'>Devolución</span> #{store} - #{transaction}".html_safe
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Buy) && inventory_operation.in? )
      "<span class='gray n'>Recojo</span> #{transaction}".html_safe
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Income) && inventory_operation.out? )
      "<span class='gray n'>Devolución</span> #{store} - #{transaction}".html_safe
    when inventory_operation.in?
      "<span class='gray n'>Ingreso</span> #{store}".html_safe
    when inventory_operation.out?
      "<span class='gray n'>Egreso</span>  #{store}".html_safe
    when inventory_operation.transout? || inventory_operation.transin?
      "<span class='gray n'>Transferencia</span> #{store} - #{inventory_operation.ref_number}".html_safe
    end
  end

  def link_related
    if inventory_operation.transference_id.present?
      trans = inventory_operation.transference
      txt = inventory_operation.operation == "transout" ? "a" : "desde"
      h.link_to "Transferencia #{txt} #{inventory_operation.store_to}", trans, :title => "Transferencia a #{inventory_operation.store_to}"
    elsif inventory_operation.contact_id.present?
      cont = inventory_operation.contact
      h.link_to cont, cont, :title => contact_tooltip
    end
  end

  def transaction_tooltip
    if inventory_operation.transaction.is_a?(Income)
      "Venta"
    else
      "Compra"
    end
  end

  def contact_tooltip
    if inventory_operation.contact.is_a?(Client)
      "Cliente"
    else
      "Proveedor"
    end
  end
end
