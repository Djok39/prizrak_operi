require "../macro_orm"
require "../constants"
require "./M_Microwave_custom"

class Microwave < Orm
  map({
    id: Int32?,
    strength: Int16,
    bounces: Int16,
    length_ms: Float64,
    length: Float64,
    timestamp: Time,
    digest: Sha1,
    data_digest: Sha1?
  })
  
  include MicrowaveCustom

  def initialize(@strength = Int16.zero,
    @bounces = Int16.zero,
    @length_ms = Float64.zero,
    @length = Float64.zero,
    @timestamp = Time::UNIX_EPOCH,
    @digest = Sha1.zero,
    @data_digest = nil)
    @id = nil
  end

  def self.permit?(input_user : User?) : Permission
    return Permission::None unless current_user = input_user
    output = current_user.priv.dev? ? Permission::All : Permission::None
    # restricted to developer only
    output
  end
end
