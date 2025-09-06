package com.jared747.assist

import io.ktor.server.application.Application
import io.ktor.server.application.call
import io.ktor.server.application.install
import io.ktor.server.features.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.routing.routing
import io.ktor.server.response.respond
import io.ktor.server.request.receive
import io.ktor.server.features.CallLogging
import kotlinx.serialization.Serializable
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

/**
 * Entry point for the backend application. This Ktor server exposes a simple REST API
 * that allows clients to manage boards, lists, tickets, and comments. The API is
 * deliberately minimal at this stage but lays the groundwork for more complex logic
 * such as user authentication, authorization, and AI-assisted operations.
 */
fun main(args: Array<String>): Unit = io.ktor.server.netty.EngineMain.main(args)

fun Application.module() {
    install(CallLogging)
    install(ContentNegotiation) {
        json()
    }

    // Initialize the database connection. See DatabaseFactory for details.
    DatabaseFactory.init()

    routing {
        get("/health") {
            call.respond(mapOf("status" to "ok"))
        }

        // Boards endpoints
        get("/boards") {
            val boards = transaction { BoardTable.selectAll().map { it[BoardTable.name] to it[BoardTable.id].value } }
            call.respond(boards)
        }
        post("/boards") {
            val request = call.receive<BoardRequest>()
            val id = transaction {
                BoardTable.insertAndGetId { it[name] = request.name }.value
            }
            call.respond(BoardResponse(id = id, name = request.name))
        }
    }
}

/** Database configuration using HikariCP and Exposed. */
object DatabaseFactory {
    fun init() {
        val url = System.getenv("DATABASE_URL") ?: "jdbc:postgresql://localhost:5432/assist"
        val user = System.getenv("DATABASE_USERNAME") ?: "assist"
        val password = System.getenv("DATABASE_PASSWORD") ?: "assist"
        val driver = "org.postgresql.Driver"
        val database = Database.connect(url = url, user = user, password = password, driver = driver)
        transaction(database) {
            SchemaUtils.create(BoardTable)
        }
    }
}

/**
 * Table definitions. Exposed uses objects derived from [IntIdTable] to represent tables
 * with auto-increment integer IDs. Relationships between tables will be added later.
 */
object BoardTable : IntIdTable("boards") {
    val name = varchar("name", length = 255)
}

@Serializable
data class BoardRequest(val name: String)

@Serializable
data class BoardResponse(val id: Int, val name: String)
