fun main() {
    val iterations = 2000

    for (interaction in (listOf(NonCaching, Caching))) {
        val testThreads = listOf(
            GetAllRequestsThread(iterations, interaction),
            GetVehicleThread(iterations, interaction),
            GetMasterThread(iterations, interaction),
            GetSSThread(iterations, interaction),
            AddMasterThread(iterations, interaction),
            ChangeMasterNameThread(iterations, interaction),
            ChangeVehicleColorThread(iterations, interaction),
            RemoveRequestThread(iterations, interaction)
        )

        testThreads.forEach { it.start() }
        testThreads.forEach { it.join() }


        println(interaction::class.java)
        println("Average")
        for (t in testThreads) {
            println("${t::class.java} : ${(t.times.sum() / t.iterations) / 1000000f}")
        }
        println("Max")
        for (t in testThreads) {
            println("${t::class.java} : ${t.times.maxByOrNull { it }!! / 1000000f}")
        }
        println("Min")
        for (t in testThreads) {
            println("${t::class.java} : ${t.times.minByOrNull { it }!! / 1000000f}")
        }
        println()
        println()
    }
}