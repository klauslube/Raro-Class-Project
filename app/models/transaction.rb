class Transaction < ApplicationRecord
  belongs_to :sender, class_name: 'Account'
  belongs_to :receiver, class_name: 'Account'

  validates :token, presence: true, uniqueness: true
  validates :status, presence: { in: %i[started authenticated pending completed canceled] }
  validates :amount, presence: true, numericality: { greater_than: 0 }

  enum :status, {
    started: 1,
    authenticated: 5,
    pending: 10,
    completed: 15,
    canceled: 20
  }, scopes: true, default: :started

  validate :check_sender_balance
  validate :check_transfer_yourself

  private

  def check_sender_balance
    errors.add(:amount, 'Insufficient balance for the transaction') if sender.balance < amount.to_f
  end

  def check_transfer_yourself
    errors.add(:receiver_id, "You can't send a transaction to yourself") if receiver_id == sender_id
  end
end
