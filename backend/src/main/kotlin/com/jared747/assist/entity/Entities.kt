package com.jared747.assist.entity

import jakarta.persistence.*
import java.time.LocalDateTime

/**
 * Represents a user in the system. Only the minimal fields required
 * for authentication and identity are stored. Additional profile
 * information can be added later if needed.
 */
@Entity
@Table(name = "users")
data class UserEntity(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,

    @Column(nullable = false, unique = true)
    var email: String = "",

    @Column(name = "password_hash", nullable = false)
    var passwordHash: String = "",

    @Column
    var name: String? = null,

    @Column(nullable = false)
    var role: String = "USER"
)

/**
 * Represents a task belonging to a user. Includes a title, optional
 * description, status and due date. Timestamps are recorded for
 * auditing and ordering. The user relationship is defined as
 * many-to-one so multiple tasks can belong to the same user.
 */
@Entity
@Table(name = "tasks")
data class TaskEntity(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    var user: UserEntity? = null,

    @Column(nullable = false)
    var title: String = "",

    @Column(columnDefinition = "TEXT")
    var description: String? = null,

    @Column(nullable = false)
    var status: String = "pending",

    @Column(name = "due_date")
    var dueDate: LocalDateTime? = null,

    @Column(name = "created_at")
    var createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at")
    var updatedAt: LocalDateTime = LocalDateTime.now()
)
