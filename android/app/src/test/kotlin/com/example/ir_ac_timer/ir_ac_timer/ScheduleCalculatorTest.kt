package com.example.ir_ac_timer.ir_ac_timer

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Calendar

class ScheduleCalculatorTest {

    private fun epochAt(year: Int, month: Int, day: Int, hour: Int, minute: Int): Long =
        Calendar.getInstance().apply {
            set(year, month, day, hour, minute, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

    private fun hourMinuteOf(epoch: Long): Pair<Int, Int> {
        val cal = Calendar.getInstance().apply { timeInMillis = epoch }
        return cal.get(Calendar.HOUR_OF_DAY) to cal.get(Calendar.MINUTE)
    }

    @Test
    fun nextDailyTrigger_laterToday_staysToday() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val trigger = ScheduleCalculator.nextDailyTrigger(now, 22, 30)
        assertTrue(trigger > now)
        assertEquals(22 to 30, hourMinuteOf(trigger))
        // Same calendar day
        assertEquals(15, Calendar.getInstance().apply { timeInMillis = trigger }
            .get(Calendar.DAY_OF_MONTH))
    }

    @Test
    fun nextDailyTrigger_alreadyPassed_rollsToTomorrow() {
        val now = epochAt(2026, Calendar.JUNE, 15, 23, 0)
        val trigger = ScheduleCalculator.nextDailyTrigger(now, 22, 30)
        assertTrue(trigger > now)
        assertEquals(16, Calendar.getInstance().apply { timeInMillis = trigger }
            .get(Calendar.DAY_OF_MONTH))
    }

    @Test
    fun nextDailyTrigger_forceTomorrow_alwaysAddsADay() {
        // Even though 22:30 is still ahead of 10:00, the post-fire reschedule
        // must target tomorrow so a recurring alarm never re-fires same day.
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val trigger = ScheduleCalculator.nextDailyTrigger(now, 22, 30, forceTomorrow = true)
        assertEquals(16, Calendar.getInstance().apply { timeInMillis = trigger }
            .get(Calendar.DAY_OF_MONTH))
    }

    @Test
    fun cycleFirstTrigger_noStartTime_isNowPlusInterval() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val trigger = ScheduleCalculator.cycleFirstTrigger(now, -1, -1, 30)
        assertEquals(now + 30 * 60_000L, trigger)
    }

    @Test
    fun cycleFirstTrigger_startTimePassed_rollsToTomorrow() {
        val now = epochAt(2026, Calendar.JUNE, 15, 23, 0)
        val trigger = ScheduleCalculator.cycleFirstTrigger(now, 22, 0, 30)
        assertEquals(22 to 0, hourMinuteOf(trigger))
        assertEquals(16, Calendar.getInstance().apply { timeInMillis = trigger }
            .get(Calendar.DAY_OF_MONTH))
    }

    @Test
    fun cycleEndEpoch_none_isZero() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        assertEquals(0L, ScheduleCalculator.cycleEndEpoch(now, -1, -1))
    }

    @Test
    fun cycleNextTrigger_withinWindow_returnsNext() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val end = now + 60 * 60_000L
        assertEquals(now + 15 * 60_000L,
            ScheduleCalculator.cycleNextTrigger(now, 15, end))
    }

    @Test
    fun cycleNextTrigger_indefinite_alwaysReturnsNext() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        assertEquals(now + 15 * 60_000L,
            ScheduleCalculator.cycleNextTrigger(now, 15, 0L))
    }

    @Test
    fun cycleNextTrigger_pastEnd_returnsNull() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val end = now + 5 * 60_000L // next (10min) would overshoot the end
        assertNull(ScheduleCalculator.cycleNextTrigger(now, 10, end))
    }

    @Test
    fun cycleBootRestoreTrigger_pastEnd_returnsNull() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val end = now - 1 // window already closed
        assertNull(ScheduleCalculator.cycleBootRestoreTrigger(now, 30, end))
    }

    @Test
    fun cycleBootRestoreTrigger_wouldOvershoot_clampsToEnd() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val end = now + 5 * 60_000L
        assertEquals(end, ScheduleCalculator.cycleBootRestoreTrigger(now, 30, end))
    }

    @Test
    fun cycleBootRestoreTrigger_withinWindow_returnsNowPlusInterval() {
        val now = epochAt(2026, Calendar.JUNE, 15, 10, 0)
        val end = now + 60 * 60_000L
        assertEquals(now + 30 * 60_000L,
            ScheduleCalculator.cycleBootRestoreTrigger(now, 30, end))
    }
}
