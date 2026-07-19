package com.example.ir_ac_timer.ir_ac_timer

import java.util.Calendar

/**
 * Pure schedule math for all three modes. Every function takes `nowMillis`
 * instead of reading the clock so the logic is unit-testable.
 *
 * Times are computed in the device's default timezone, matching the
 * previous inline Calendar usage.
 */
object ScheduleCalculator {

    /**
     * Next occurrence of [hour]:[minute].
     * With [forceTomorrow] the result is always tomorrow's occurrence —
     * this is the post-fire reschedule used by AlarmReceiver, which must
     * not re-arm today even when the wall clock still reads before HH:MM.
     */
    fun nextDailyTrigger(nowMillis: Long, hour: Int, minute: Int, forceTomorrow: Boolean = false): Long {
        val cal = Calendar.getInstance().apply {
            timeInMillis = nowMillis
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        if (forceTomorrow || cal.timeInMillis <= nowMillis) {
            cal.add(Calendar.DAY_OF_YEAR, 1)
        }
        return cal.timeInMillis
    }

    /**
     * First trigger of a cycle: at the user's start time (pushed to tomorrow
     * if already passed), or now + interval when no start time was given.
     */
    fun cycleFirstTrigger(nowMillis: Long, startHour: Int, startMinute: Int, intervalMin: Int): Long =
        if (startHour >= 0 && startMinute >= 0) {
            nextDailyTrigger(nowMillis, startHour, startMinute)
        } else {
            nowMillis + intervalMin * 60_000L
        }

    /** Cycle end epoch, or 0L when no end time was given. */
    fun cycleEndEpoch(nowMillis: Long, endHour: Int, endMinute: Int): Long =
        if (endHour >= 0 && endMinute >= 0) {
            nextDailyTrigger(nowMillis, endHour, endMinute)
        } else {
            0L
        }

    /**
     * Next cycle trigger after a fire, or null when the window is over.
     * endEpochMillis == 0L means an indefinite cycle.
     */
    fun cycleNextTrigger(nowMillis: Long, intervalMin: Int, endEpochMillis: Long): Long? {
        val next = nowMillis + intervalMin * 60_000L
        return if (endEpochMillis == 0L || next < endEpochMillis) next else null
    }

    /**
     * Trigger to restore a cycle after reboot: null when the window already
     * ended; otherwise now + interval, clamped to the end time so the final
     * fire still happens at the window edge.
     */
    fun cycleBootRestoreTrigger(nowMillis: Long, intervalMin: Int, endEpochMillis: Long): Long? {
        if (endEpochMillis != 0L && nowMillis >= endEpochMillis) return null
        val next = nowMillis + intervalMin * 60_000L
        return if (endEpochMillis != 0L && next >= endEpochMillis) endEpochMillis else next
    }
}
