class AddPaymentToCourseAccesses < ActiveRecord::Migration[7.1]
  def change
    add_reference :course_accesses, :payment, foreign_key: true
  end
end
