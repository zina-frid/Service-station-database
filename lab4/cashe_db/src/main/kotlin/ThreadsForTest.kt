import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import java.util.concurrent.CyclicBarrier

private fun connectToDatabase() {
    fun hikari(): HikariDataSource {
        val config = HikariConfig()
        config.driverClassName = "org.postgresql.Driver"
        config.jdbcUrl = "jdbc:postgresql://127.0.0.1:5432/services"
        config.username = "postgres"
        config.password = "0409"
        config.maximumPoolSize = 10
        config.isAutoCommit = false
        config.addDataSourceProperty("cachePrepStmts", "false")

        config.transactionIsolation = "TRANSACTION_READ_COMMITTED"

        config.validate()
        return HikariDataSource(config)
    }

    Database.connect(hikari())
}

private val cyclicBarrier = CyclicBarrier(8)

abstract class TestThread(val iterations: Int, val interaction: Interaction) : Thread() {
    val times = mutableListOf<Long>()
}

class GetAllRequestsThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        while (cyclicBarrier.numberWaiting < 4) {
            val start = System.nanoTime()
            interaction.getAllRequests()
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}

class GetVehicleThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val veh_id = transaction { vehicle.selectAll().map { it[vehicle.vehicle_id] } }

        while (cyclicBarrier.numberWaiting < 4) {
            val start = System.nanoTime()
            interaction.getVehicle(veh_id.random())
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}

class GetMasterThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val mast_id = transaction { master.selectAll().map { it[master.master_id] } }

        while (cyclicBarrier.numberWaiting < 4) {
            val start = System.nanoTime()
            interaction.getMaster(mast_id.random())
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}

class GetSSThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val ss_id = transaction { service_station.selectAll().map { it[service_station.service_station_id] } }

        while (cyclicBarrier.numberWaiting < 4) {

            val start = System.nanoTime()
            interaction.getSS(ss_id.random())
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}

class AddMasterThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val ss_id = transaction { service_station.selectAll().map { it[service_station.service_station_id] } }
        val spec_id = transaction { specialization.selectAll().map { it[specialization.specialization_id] } }

        repeat(iterations) {
            val start = System.nanoTime()
            interaction.addMaster("NewMaster", ss_id.random(), spec_id.random())
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}

class ChangeMasterNameThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val master_id = transaction { master.selectAll().map { it[master.master_id] } }

        repeat(iterations) {
            val start = System.nanoTime()
            interaction.changeMasterName(master_id.random(), "ChangedName")
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}

class ChangeVehicleColorThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val vehicle_id = transaction { vehicle.selectAll().map { it[vehicle.vehicle_id] } }

        repeat(iterations) {
            val start = System.nanoTime()
            interaction.changeVehicleColor(vehicle_id.random(), "new_color")
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}


class RemoveRequestThread(iterations: Int, interaction: Interaction) : TestThread(iterations, interaction) {
    override fun run() {
        connectToDatabase()

        cyclicBarrier.await()

        val request_id = transaction { request.selectAll().map { it[request.request_id] } }

        repeat(iterations) {
            val start = System.nanoTime()
            interaction.removeRequest(request_id.random())
            times.add(System.nanoTime() - start)
        }
        cyclicBarrier.await()
    }
}