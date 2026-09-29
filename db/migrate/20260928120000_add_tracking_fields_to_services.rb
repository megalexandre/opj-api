# frozen_string_literal: true

class AddTrackingFieldsToServices < ActiveRecord::Migration[8.1]
  def change
    change_table :services, bulk: true do |t|
      t.string :protocol
      t.string :status
      t.string :timeline
      t.string :timeline_comments
      t.string :reference_point
      t.string :approval_status
      t.string :document_category
      t.string :reused_documents
    end
  end
end
