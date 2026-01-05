require "rails_helper"

RSpec.describe "Admin dashboard", type: :system do
  let!(:admin) { User.create!(full_name: "Admin User", email: "admin@example.com", password: "password", role: :admin) }

  before do
    driven_by(:rack_test)
    visit login_path
    fill_in "email", with: admin.email
    fill_in "password", with: "password"
    click_button "Sign in"
  end

  it "shows admin overview" do
    expect(page).to have_content("Admin Dashboard")
    expect(page).to have_content("Total Users")
  end

  it "can add a new teacher" do
    click_link "Add Teacher" # assuming link_to in admin dashboard
    fill_in "Full name", with: "New Teacher"
    fill_in "Email", with: "teacher1@example.com"
    fill_in "Password", with: "password"
    click_button "Create Teacher"

    expect(page).to have_content("Teacher created successfully")
    expect(User.last.role).to eq("teacher")
  end

  it "can edit a teacher" do
    teacher = User.create!(full_name: "Teacher Old", email: "oldteacher@example.com", password: "password", role: :teacher)
    click_link "Edit", href: "/admin/dashboard/edit_teachers/#{teacher.id}"
    fill_in "Full name", with: "Teacher New"
    click_button "Update Teacher"

    expect(page).to have_content("Teacher updated successfully")
    expect(teacher.reload.full_name).to eq("Teacher New")
  end

  it "can delete a teacher" do
    teacher = User.create!(full_name: "Teacher Delete", email: "todelete@example.com", password: "password", role: :teacher)
    click_link "Delete", href: "/admin/dashboard/destroy_teachers/#{teacher.id}"

    expect(page).to have_content("Teacher deleted successfully")
    expect(User.exists?(teacher.id)).to be_falsey
  end
end
