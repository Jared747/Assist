package com.jared747.assist.controller

import com.jared747.assist.entity.UserEntity
import com.jared747.assist.entity.TaskEntity
import com.jared747.assist.service.UserService
import com.jared747.assist.service.TaskService
import com.jared747.assist.service.AssistantService
import com.jared747.assist.repository.UserRepository
import com.jared747.assist.config.JwtUtil
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime

/**
 * Handles authentication-related endpoints such as registration and login.
 * On successful registration or login, a JWT token is returned to the client.
 */
@RestController
class AuthController(
    private val userService: UserService,
    private val jwtUtil: JwtUtil
) {
    data class RegisterRequest(val email: String, val password: String, val name: String?)
    data class LoginRequest(val email: String, val password: String)
    data class AuthResponse(val token: String)

    @PostMapping("/register")
    fun register(@RequestBody request: RegisterRequest): ResponseEntity<Any> {
        return try {
            val user = userService.register(request.email, request.password, request.name)
            val token = jwtUtil.generateToken(user)
            ResponseEntity.ok(AuthResponse(token))
        } catch (ex: Exception) {
            ResponseEntity.badRequest().body(mapOf("error" to ex.message))
        }
    }

    @PostMapping("/login")
    fun login(@RequestBody request: LoginRequest): ResponseEntity<Any> {
        val user = userService.authenticate(request.email, request.password)
            ?: return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(mapOf("error" to "Invalid credentials"))
        val token = jwtUtil.generateToken(user)
        return ResponseEntity.ok(AuthResponse(token))
    }
}

/**
 * Handles CRUD operations on tasks for the authenticated user. All
 * endpoints here require a valid JWT token supplied in the
 * Authorization header. The Authentication object provided by Spring
 * Security contains the authenticated UserEntity (set in the JWT
 * filter).
 */
@RestController
@RequestMapping("/tasks")
class TaskController(
    private val taskService: TaskService
) {
    data class CreateTaskRequest(val title: String, val description: String?, val dueDate: LocalDateTime?)
    data class UpdateTaskRequest(val status: String?, val dueDate: LocalDateTime?)
    data class TaskDTO(val id: Long, val title: String, val description: String?, val status: String, val dueDate: String?) {
        companion object {
            fun fromEntity(task: TaskEntity) = TaskDTO(
                id = task.id ?: 0L,
                title = task.title,
                description = task.description,
                status = task.status,
                dueDate = task.dueDate?.toString()
            )
        }
    }

    @GetMapping
    fun getTasks(auth: Authentication): List<TaskDTO> {
        val user = auth.principal as UserEntity
        return taskService.getTasks(user).map { TaskDTO.fromEntity(it) }
    }

    @PostMapping
    fun addTask(auth: Authentication, @RequestBody req: CreateTaskRequest): TaskDTO {
        val user = auth.principal as UserEntity
        val task = taskService.createTask(user, req.title, req.description, req.dueDate)
        return TaskDTO.fromEntity(task)
    }

    @PutMapping("/{id}")
    fun updateTask(auth: Authentication, @PathVariable id: Long, @RequestBody req: UpdateTaskRequest): TaskDTO {
        val user = auth.principal as UserEntity
        val task = taskService.updateTask(user, id, req.status, req.dueDate)
        return TaskDTO.fromEntity(task)
    }

    @DeleteMapping("/{id}")
    fun deleteTask(auth: Authentication, @PathVariable id: Long) {
        val user = auth.principal as UserEntity
        taskService.deleteTask(user, id)
    }
}

/**
 * Endpoint for interacting with the AI assistant. Accepts a user
 * message and returns a response containing the assistant's reply
 * along with any actions performed on tasks. In a full
 * implementation, this controller would delegate to a service that
 * connects to OpenAI and interprets the natural language.
 */
@RestController
class AssistantController(
    private val assistantService: AssistantService
) {
    data class AssistantRequest(val message: String)

    @PostMapping("/assistant")
    fun chat(auth: Authentication, @RequestBody req: AssistantRequest): ResponseEntity<Map<String, Any>> {
        val user = auth.principal as UserEntity
        val response = assistantService.handleUserMessage(user, req.message)
        return ResponseEntity.ok(response)
    }
}
