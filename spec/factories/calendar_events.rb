FactoryBot.define do
  factory :calendar_event do
    project { nil }
    date { Date.current }
    content { { title: 'Evento' } }
  end
end
