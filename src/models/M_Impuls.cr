require "../macro_orm"
require "../constants"
require "./M_Impuls_custom"
require "./M_Microwave"

class Impuls < Orm
  map({
    microwave_id: Int32,
    logic: Bool,
    strength: Int16,
    edge: Int32,
    ns100: Int32
  })
  has :parent, Microwave
  include ImpulsCustom

  def initialize(@microwave_id = Int32.zero,
    @logic = false,
    @strength = Int16.zero,
    @edge = Int32.zero,
    @ns100 = Int32.zero)
    
  end

  def self.permit?(input_user : User?) : Permission
    return Permission::None unless current_user = input_user
    output = current_user.priv.dev? ? Permission::All : Permission::None
    # restricted to developer only
    output
  end
end
