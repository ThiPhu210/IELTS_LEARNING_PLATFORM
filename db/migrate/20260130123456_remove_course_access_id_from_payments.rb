class RemoveCourseAccessIdFromPayments < ActiveRecord::Migration[8.0]
def change
  remove_reference :payments, :course_access, foreign_key: true
end
end
