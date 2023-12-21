package com.example.arm

import androidx.test.core.app.ActivityScenario
import androidx.test.espresso.Espresso
import androidx.test.espresso.assertion.ViewAssertions
import androidx.test.espresso.idling.CountingIdlingResource
import androidx.test.espresso.matcher.ViewMatchers
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.After

import org.junit.Test
import org.junit.runner.RunWith

import org.junit.Assert.*
import org.junit.Before

/**
 * Instrumented test, which will execute on an Android device.
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
@RunWith(AndroidJUnit4::class)
class ExampleInstrumentedTest {
    private lateinit var activityScenario: ActivityScenario<MainActivity>
    private val idlingResource = CountingIdlingResource("idlingResource")

    @Before
    fun setUp() {
//        IdlingRegistry.getInstance().register(idlingResource)
        activityScenario = ActivityScenario.launch(MainActivity::class.java)
    }

    @Test
    fun setNewQuantity_sum_increasesTextField(){

//        activityRule.scenario.moveToState(Lifecycle.State.RESUMED)
//        IdlingPolicies.setMasterPolicyTimeout(30, TimeUnit.SECONDS)
//        IdlingPolicies.setIdlingResourceTimeout(30, TimeUnit.SECONDS)
//
//        idlingResource.increment()

        Espresso.onView(withId(R.id.etNewQuantity))
            .check((ViewAssertions.matches(ViewMatchers.withText("1"))))

//        idlingResource.decrement()

//        onView(withId(R.id.ibSum))
//            .perform(click())
//
//        onView(withId(R.id.etNewQuantity))
//            .check((matches(withText("2"))))
    }

    @After
    fun tearDown() {
//        IdlingRegistry.getInstance().unregister(idlingResource)
        activityScenario.close()
    }
}