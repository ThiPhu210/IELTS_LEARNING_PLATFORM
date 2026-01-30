class EnsurePaymentOnCourseAccesses < ActiveRecord::Migration[7.1]

def change
  add_reference :course_accesses, :payment, foreign_key: true unless column_exists?(:course_accesses, :payment_id)
end
end
