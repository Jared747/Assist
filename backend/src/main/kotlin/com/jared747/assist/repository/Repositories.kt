package com.jared747.assist.repository

import com.jared747.assist.entity.TaskEntity
import com.jared747.assist.entity.UserEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

/**
 * Repository for accessing user data. Provides CRUD operations and
 * a convenience method for finding users by email, which is the
 * unique identifier used for login.
 */
@Repository
interface UserRepository : JpaRepository<UserEntity, Long> {
    fun findByEmail(email: String): UserEntity?
}

/**
 * Repository for accessing tasks. Allows finding tasks by the owning
 * user. Note that we only expose methods we actually need; Spring
 * Data JPA will generate the implementations automatically.
 */
@Repository
interface TaskRepository : JpaRepository<TaskEntity, Long> {
    fun findByUser(user: UserEntity): List<TaskEntity>
}
