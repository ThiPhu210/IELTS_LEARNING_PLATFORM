
class RemoveCourseAccessFromPayments < ActiveRecord::Migration[7.1]
def change
  remove_reference :payments, :course_access, foreign_key: true
end
end
