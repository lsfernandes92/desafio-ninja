# frozen_string_literal: true

class AddRoomIdToAppointments < ActiveRecord::Migration[7.0]
  def change
    add_column :appointments, :room_id, :string, null: false, foreign_key: true
  end
end
