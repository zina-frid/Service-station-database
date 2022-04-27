sealed interface Key

data class VehicleKey(private val vehicle_id: Int) : Key

data class MasterKey(private val master_id: Int) : Key

data class SSKey(private val ss_id: Int) : Key

object AllRequestsKey : Key