require "../macro_orm"
require "../constants"
require "./M_En_custom"

class En < Orm
  map({
    id: Int32?,
    digest: Sha256,
    data_digest: Sha256?
  })
  
  include EnCustom

  def initialize(@digest = Sha256.zero,
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
