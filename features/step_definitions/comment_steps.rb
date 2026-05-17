# frozen_string_literal: true

Dado('que existe um projeto com um status cadastrado') do
  @customer = create(:customer)
  @project  = create(:project, client: @customer)
  @status   = create(:project_status, project: @project)
end

Dado('que existe um comentário cadastrado') do
  @comment = create(:project_status_comment, project_status: @status)
end

Então('o status tem {int} comentário') do |count|
  expect(@status.reload.comments.count).to eq(count)
end

Então('o comentário não existe mais no banco') do
  expect(ProjectStatusComment.exists?(@comment.id)).to be false
end
