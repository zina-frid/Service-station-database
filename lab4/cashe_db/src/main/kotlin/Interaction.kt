import org.jetbrains.exposed.sql.ResultRow

interface Interaction {
    fun getAllRequests() : List<ResultRow>

    fun addMaster(name: String, ss_id: Int, spec_id: Int)

    fun getVehicle(vehicle_id: Int) : List<ResultRow>

    fun getMaster(master_id: Int) : List<ResultRow>

    fun changeMasterName(master_id: Int, new_name: String)

    fun changeVehicleColor(vehicle_id: Int, new_color: String)

    fun getSS(ss_id: Int) : List<ResultRow>

    fun removeRequest(request_id: Int)
}