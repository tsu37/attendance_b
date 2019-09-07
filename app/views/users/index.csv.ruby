require 'csv'

CSV.generate do |csv|
  csv_column_names = %w(name  email)
  csv << csv_column_names
  @users.each do |user|
    csv_column_values = [
      user.name,
      user.email
    ]
    csv << csv_column_values
  end
end