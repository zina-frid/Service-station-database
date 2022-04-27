import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

object NonCaching : Interaction {

    override fun getAllRequests() =
        transaction { request.selectAll().toList() }

    override fun getVehicle(vehicle_id: Int) =
        transaction { vehicle.select { vehicle.vehicle_id eq vehicle_id }.toList() }

    override fun getMaster(master_id: Int) =
        transaction { master.select { master.master_id eq master_id }.toList() }

    override fun getSS(ss_id: Int) =
        transaction { service_station.select { service_station.service_station_id eq ss_id }.toList() }

    override fun addMaster(name: String, ss_id: Int, spec_id: Int) {
        transaction {
            master.insert {
                it[master_name] = name
                it[service_station_id] = ss_id
                it[specialization_id] = spec_id
            }
        }
    }

    override fun changeMasterName(master_id: Int, new_name: String) {
        transaction {
            master.update({ master.master_id eq master_id }) {
                it[master_name] = new_name
            }
        }
    }

    override fun changeVehicleColor(vehicle_id: Int, new_color: String) {
        transaction {
            vehicle.update({ vehicle.vehicle_id eq vehicle_id }) {
                it[color] = new_color
            }
        }
    }

    override fun removeRequest(request_id: Int) {
        transaction {
            request.deleteWhere { request.request_id eq request_id }
        }
    }

}