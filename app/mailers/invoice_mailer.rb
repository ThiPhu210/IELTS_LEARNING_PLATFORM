# app/mailers/invoice_mailer.rb
class InvoiceMailer < ApplicationMailer
  default from: "no-reply@yourapp.com"

  def invoice_email(order)
    @order  = order
    @user   = order.user
    @course = order.course

    mail(
      to: @user.email,
      subject: "Hóa đơn thanh toán khóa học #{@course.title}"
    )
  end
end
