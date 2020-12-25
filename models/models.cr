# Models, that represents database
require "./base_model"

class Microwave < BaseModel
  acl(Dev)
  table :microwave, Gen.flags(Id, Model, Overwrite, AlterAny, MacroOrm, RelationsAny) do
    column strength : Int16
    column bounces : Int16
    column length_ms : Float64
    column length : Float64 # in sec
    column timestamp : Time, flags: ColumnFlags.flags(Precision6, Unique)
    column digest : Sha1
    column data_digest : Sha1?
    has_many impuls : Impuls# , foreign_key: microwave_id
  end
end

class Impuls < BaseModel
  acl(Dev)
  table :impuls, Gen.flags(Model, Overwrite, AlterAny, MacroOrm, RelationsAny) do
    belongs_to microwave : Microwave

    column logic : Bool
    column strength : Int16
    column edge : Int32
    column ns100 : Int32
  end
end
