# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.to_s + '/swagger'

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'OPJ API',
        version: 'v1'
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Desenvolvimento' }
      ],
      security: [{ bearerAuth: [] }],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          Address: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              link: { type: :string, nullable: true },
              place: { type: :string, nullable: true },
              cep: { type: :string, nullable: true },
              number: { type: :string, nullable: true },
              address: { type: :string, nullable: true },
              complement: { type: :string, nullable: true },
              neighborhood: { type: :string, nullable: true },
              city: { type: :string, nullable: true },
              state: { type: :string, nullable: true },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id]
          },
          Customer: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string, nullable: true },
              email: { type: :string, nullable: true },
              tax_id: { type: :string, nullable: true },
              phone: { type: :string, nullable: true },
              address: { '$ref' => '#/components/schemas/Address', nullable: true },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id]
          },
          Concessionaire: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string, nullable: true },
              acronym: { type: :string, nullable: true },
              code: { type: :string, nullable: true },
              region: { type: :string, nullable: true },
              phone: { type: :string, nullable: true },
              email: { type: :string, nullable: true },
              active: { type: :boolean, nullable: true },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id]
          },
          Coordinates: {
            type: :object,
            nullable: true,
            properties: {
              latitude: { type: :number, format: :float },
              longitude: { type: :number, format: :float }
            },
            required: %w[latitude longitude]
          },
          Project: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              client_id: { type: :string, format: :uuid },
              address_id: { type: :string, format: :uuid, nullable: true },
              utility_company: { type: :string },
              utility_protocol: { type: :string },
              secondary_protocol: { type: :string, nullable: true },
              customer_class: { type: :string },
              integrator: { type: :string, format: :uuid, nullable: true },
              integrator_name: { type: :string, nullable: true },
              modality: { type: :string },
              framework: { type: :string },
              status: { type: :string, nullable: true },
              amount: { type: :string, nullable: true },
              dc_protection: { type: :string, nullable: true },
              system_power: { type: :number, format: :float, nullable: true },
              unit_control: { type: :string },
              description: { type: :string, nullable: true },
              project_type: { type: :string },
              fast_track: { type: :boolean },
              coordinates: { '$ref' => '#/components/schemas/Coordinates' },
              services_names: { type: :array, items: { type: :string }, nullable: true },
              editable: { type: :boolean },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id client_id utility_company utility_protocol customer_class
                         modality framework unit_control project_type fast_track]
          },
          Upload: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              item_id: { type: :string, format: :uuid },
              filename: { type: :string },
              url_s3: { type: :string },
              size: { type: :integer },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id item_id filename url_s3 size]
          },
          Page: {
            type: :object,
            properties: {
              content: { type: :array, items: { type: :object } },
              totalElements: { type: :integer },
              totalPages: { type: :integer },
              size: { type: :integer },
              number: { type: :integer },
              numberOfElements: { type: :integer },
              first: { type: :boolean },
              last: { type: :boolean },
              empty: { type: :boolean }
            }
          },
          ProjectStatusComment: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              body: { type: :string },
              status_id: { type: :string, format: :uuid },
              created_by: { type: :string, format: :uuid, nullable: true },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id body status_id]
          },
          ProjectStatus: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              project_id: { type: :string, format: :uuid },
              comments: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string, format: :uuid },
                    body: { type: :string },
                    created_by: { type: :string, format: :uuid, nullable: true },
                    created_at: { type: :string, format: :'date-time' }
                  }
                }
              },
              created_by: { type: :string, format: :uuid, nullable: true },
              created_at: { type: :string, format: :'date-time' }
            },
            required: %w[id name project_id]
          },
          TechnicalDetail: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              project_id: { type: :string, format: :uuid },
              opening_date: { type: :string, format: :date, nullable: true },
              supply_voltage: { type: :string, nullable: true },
              new_project: { type: :boolean },
              zero_grid_control: { type: :boolean },
              modules: { type: :array, items: { type: :string } },
              inverters: { type: :array, items: { type: :string } },
              entry_standard_items: { type: :array, items: { type: :string } },
              credit_divisions: { type: :array, items: { type: :string } },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' },
              created_by: { type: :string, format: :uuid, nullable: true },
              updated_by: { type: :string, format: :uuid, nullable: true }
            },
            required: %w[id project_id new_project zero_grid_control]
          },
          Error: {
            type: :object,
            properties: {
              message: { type: :string }
            }
          },
          User: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              email: { type: :string },
              profile: { type: :string },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id name email profile]
          },
          AuthToken: {
            type: :object,
            properties: {
              token: { type: :string },
              user: { '$ref' => '#/components/schemas/User' }
            },
            required: %w[token user]
          },
          Apportionment: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              service_id: { type: :string, format: :uuid },
              consumer_unit: { type: :string },
              address: { type: :string },
              classification: { type: :string },
              percentage: { type: :integer },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id service_id consumer_unit address classification percentage]
          },
          ServiceEntryItem: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              service_id: { type: :string, format: :uuid },
              connection_type: { type: :string },
              classification: { type: :string },
              quantity: { type: :integer },
              circuit_breaker: { type: :string },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id service_id connection_type classification quantity circuit_breaker]
          },
          Service: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              service_type: { type: :string },
              customer_id: { type: :string, format: :uuid },
              concessionaire_id: { type: :string, format: :uuid },
              opening_date: { type: :string, format: :date },
              amount: { type: :string },
              discount_coupon_percentage: { type: :integer, nullable: true },
              observations: { type: :string, nullable: true },
              supply_voltage: { type: :string, nullable: true },
              coordinates: { '$ref' => '#/components/schemas/Coordinates' },
              generating_consumer_unit: { type: :string, nullable: true },
              pole_distance_over_30m: { type: :boolean },
              construction_address_id: { type: :string, format: :uuid, nullable: true },
              generating_address_id: { type: :string, format: :uuid, nullable: true },
              apportionments: { type: :array, items: { '$ref' => '#/components/schemas/Apportionment' } },
              service_entry_items: { type: :array,
                                     items: { '$ref' => '#/components/schemas/ServiceEntryItem' } },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' },
              created_by: { type: :string, format: :uuid, nullable: true },
              updated_by: { type: :string, format: :uuid, nullable: true }
            },
            required: %w[id service_type customer_id concessionaire_id opening_date amount pole_distance_over_30m]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
