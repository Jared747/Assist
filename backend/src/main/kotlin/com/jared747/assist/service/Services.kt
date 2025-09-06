package com.jared747.assist.service

import com.jared747.assist.entity.TaskEntity
import com.jared747.assist.entity.UserEntity
import com.jared747.assist.repository.TaskRepository
import com.jared747.assist.repository.UserRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

/**
 * Service handling user operations such as registration and
 * authentication. Passwords are hashed using the provided
 * PasswordEncoder. Throws exceptions on duplicates or validation
 * failures; the controller layer is responsible for translating
 * these into HTTP responses.
 */
@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) {
    fun register(email: String, password: String, name: String?): UserEntity {
        val existing = userRepository.findByEmail(email)
        if (existing != null) {
            throw IllegalArgumentException("Email already exists")
        }
        val user = UserEntity(
            email = email,
            passwordHash = passwordEncoder.encode(password),
            name = name
        )
        return userRepository.save(user)
    }

    fun authenticate(email: String, password: String): UserEntity? {
        val user = userRepository.findByEmail(email) ?: return null
        return if (passwordEncoder.matches(password, user.passwordHash)) user else null
    }
}

/**
 * Service managing task lifecycle. Methods enforce that a user can only
 * operate on their own tasks. Data access is delegated to the
 * TaskRepository. Transactional boundaries ensure atomicity on
 * updates.
 */
@Service
class TaskService(
    private val taskRepository: TaskRepository
) {
    @Transactional
    fun createTask(user: UserEntity, title: String, description: String?, dueDate: LocalDateTime?): TaskEntity {
        val task = TaskEntity(
            user = user,
            title = title,
            description = description,
            status = "pending",
            dueDate = dueDate
        )
        return taskRepository.save(task)
    }

    fun getTasks(user: UserEntity): List<TaskEntity> = taskRepository.findByUser(user)

    @Transactional
    fun updateTask(user: UserEntity, id: Long, status: String?, dueDate: LocalDateTime?): TaskEntity {
        val task = taskRepository.findById(id).orElseThrow { RuntimeException("Task not found") }
        if (task.user?.id != user.id) throw RuntimeException("Unauthorized")
        status?.let { task.status = it }
        dueDate?.let { task.dueDate = it }
        task.updatedAt = LocalDateTime.now()
        return taskRepository.save(task)
    }

    @Transactional
    fun deleteTask(user: UserEntity, id: Long) {
        val task = taskRepository.findById(id).orElseThrow { RuntimeException("Task not found") }
        if (task.user?.id != user.id) throw RuntimeException("Unauthorized")
        taskRepository.delete(task)
    }
}

/**
 * Stub implementation of the assistant service. This service will be
 * responsible for orchestrating calls to the OpenAI API (or other
 * models) in order to interpret natural language commands and act on
 * behalf of the user. At present it simply returns a placeholder
 * response with the current tasks. Real integration with an AI
 * endpoint can be added by replacing the implementation in
 * [handleUserMessage].
 */
@Service
class AssistantService(
    private val taskRepository: TaskRepository
) {
    fun handleUserMessage(user: UserEntity, message: String): Map<String, Any> {
        // Retrieve current tasks for context; real implementation would
        // build a prompt with this list and call the OpenAI API.
        val tasks = taskRepository.findByUser(user)
        val tasksInfo = tasks.map { mapOf("id" to it.id, "title" to it.title, "status" to it.status) }
        // TODO: Integrate with OpenAI or other LLM here.
        return mapOf(
            "assistantMessage" to "AI integration not implemented yet",
            "tasks" to tasksInfo
        )
    }
}
