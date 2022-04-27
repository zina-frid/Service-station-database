import org.jetbrains.exposed.sql.ResultRow

object Caching : Interaction {

    private val cache = CacheBasedOnLRU<Key, List<ResultRow>>(2048)

    override fun getAllRequests() =
        cache.getOrPut(AllRequestsKey) { NonCaching.getAllRequests() }

      override fun getVehicle(vehicle_id: Int) =
        cache.getOrPut(VehicleKey(vehicle_id)) { NonCaching.getVehicle(vehicle_id) }

    override fun getMaster(master_id: Int) =
        cache.getOrPut(MasterKey(master_id)) { NonCaching.getMaster(master_id) }

    override fun getSS(ss_id: Int) =
        cache.getOrPut(SSKey(ss_id)) { NonCaching.getSS(ss_id) }

    override fun addMaster(name: String, ss_id: Int, spec_id: Int) {
        NonCaching.addMaster(name, ss_id, spec_id)
    }

    override fun changeMasterName(master_id: Int, new_name: String) {
        cache.remove(MasterKey(master_id))

        NonCaching.changeMasterName(master_id, new_name)
    }

    override fun changeVehicleColor(vehicle_id: Int, new_color: String) {
        cache.remove(VehicleKey(vehicle_id))

        NonCaching.changeVehicleColor(vehicle_id, new_color)
    }

    override fun removeRequest(request_id: Int) {
        cache.remove(AllRequestsKey)

        NonCaching.removeRequest(request_id)
    }


}