require "../macro_orm"
require "../constants"
require "./M_Elon_custom"

class Elon < Orm
  map({
    id: Int32?,
    digest: Hptapod,
    data_digest: Hptapod?
  })
  
  include ElonCustom

  def initialize(@digest = Hptapod.zero,
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
