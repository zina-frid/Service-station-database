import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.ReferenceOption


object vehicle: Table("vehicle") {
    val vehicle_id = integer("vehicle_id").autoIncrement().uniqueIndex()
    val vehicle_type = customEnumeration(
        "vehicle_type",
        "body",
        { value -> BODY.valueOf(value as String) },
        { PGEnum("body", it) })
        val car_number = char("car_number", length = 6)
    val model = text("model")
    val manufacture_year = char("manufacture_year", length = 4)
    val color = text("color")
    val engine_capacity = decimal("engine_capacity", 2, 1)
    val transmission = customEnumeration(
        "transmission",
        "transmission_type",
        { value -> TRANSMISSION_TYPE.valueOf(value as String) },
        { PGEnum("transmission_type", it) })

    override val primaryKey = PrimaryKey(vehicle_id)
}

object service_station : Table("service_station") {
    val service_station_id = integer("service_station_id").autoIncrement().uniqueIndex()
    val address = text("address").uniqueIndex()

    override val primaryKey = PrimaryKey(service_station_id)
}

object specialization : Table("specialization") {
    val specialization_id = integer("specialization_id").autoIncrement().uniqueIndex()
    val specialization = text("specialization").uniqueIndex()

    override val primaryKey = PrimaryKey(specialization_id)
}

object master : Table("master") {
    val master_id = integer("master_id").autoIncrement().uniqueIndex()
    val master_name = text("master_name")
    val service_station_id = integer("service_station_id").references(service_station.service_station_id)
    val specialization_id = integer("specialization_id").references(specialization.specialization_id)

    override val primaryKey = PrimaryKey(master_id)
}

object request_cost : Table("request_cost") {
    val cost_id = integer("cost_id").autoIncrement().uniqueIndex()
    val final_cost = integer("final_cost")
    val spare_parts_cost = integer("spare_parts_cost").default(0)
    val consumable_cost = integer("consumable_cost").default(0)
    val others_cost = integer("others_cost").default(0)
    val man_hours_cost = integer("man_hours_cost").default(0)

    override val primaryKey = PrimaryKey(cost_id)
}

object work_type : Table("work_type") {
    val work_type_id = integer("work_type_id").autoIncrement().uniqueIndex()
    val maintenance = customEnumeration(
        "maintenance",
        "maintenance",
        { value -> MAINTENANCE_TYPE.valueOf(value as String) },
        { PGEnum("maintenance", it) })
    val specialization_id = integer("specialization_id").references(specialization.specialization_id)

    override val primaryKey = PrimaryKey(work_type_id)
}

object durationn : Table("duration") {
    val duration_id = integer("duration_id").autoIncrement().uniqueIndex()
    val request_date = date("request_date")
    val completion_date = date("completion_date")

    override val primaryKey = PrimaryKey(duration_id)
}

object request : Table("request") {
    val request_id = integer("request_id").autoIncrement().uniqueIndex()
    val vehicle_id = integer("vehicle_id").references(vehicle.vehicle_id, onDelete = ReferenceOption.RESTRICT)
    val duration_id = integer("duration_id").references(durationn.duration_id)
    val work_type_id = integer("work_type_id").references(work_type.work_type_id, onDelete = ReferenceOption.RESTRICT)
    val status = customEnumeration(
        "status",
        "request_status",
        { value -> REQUEST_STATUS.valueOf(value as String) },
        { PGEnum("request_status", it) })
    val master_id = integer("master_id").references(master.master_id, onDelete = ReferenceOption.RESTRICT)
    val service_station_id = integer("service_station_id").references(service_station.service_station_id, onDelete = ReferenceOption.RESTRICT)
    val cost_id = integer("cost_id").references(request_cost.cost_id)

    override val primaryKey = PrimaryKey(request_id)
}

object spare_parts : Table("spare_parts"){
    val part_id = integer("part_id").autoIncrement().uniqueIndex()
    val part_name = text("part_name").uniqueIndex()
    val part_in_stock = bool("part_in_stock")

    override val primaryKey = PrimaryKey(part_id)
}


object parts_for_request : Table("parts_for_request"){
    val request_id = integer("request_id").references(request.request_id, onDelete = ReferenceOption.CASCADE)
    val part_id = integer("part_id").references(spare_parts.part_id, onDelete = ReferenceOption.RESTRICT)

    init {
        index(true, request_id, part_id)
    }

    val part_amount = integer("part_amount").check { it greaterEq 0 }
}

object consumables : Table("spare_parts"){
    val cons_id = integer("cons_id").autoIncrement().uniqueIndex()
    val cons_name = text("cons_name").uniqueIndex()
    val cons_in_stock = bool("cons_in_stock")

    override val primaryKey = PrimaryKey(cons_id)
}

object cons_for_request : Table("cons_for_request"){
    val request_id = integer("request_id").references(request.request_id, onDelete = ReferenceOption.CASCADE)
    val cons_id = integer("cons_id").references(consumables.cons_id, onDelete = ReferenceOption.RESTRICT)

    init {
        index(true, request_id, cons_id)
    }

    val cons_amount = integer("cons_amount").check { it greaterEq 0 }

}
