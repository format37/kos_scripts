print "launcher v.0".
                                                                                                                     
//init logs                                                                                         
set session_start to time.
set session_step to 0.
                                                                                                                     
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.                                                              
                                                                                                                     
//This is a trigger that constantly checks to see if our thrust is zero.                                             
//If it is, it will attempt to stage and then return to where the script                                             
//left off. The PRESERVE keyword keeps the trigger active even after it                                              
//has been triggered.                                                                                                
WHEN MAXTHRUST = 0 THEN {                                                                                            
    PRINT "Staging".                                                                                                 
    STAGE.                                                                                                           
    PRESERVE.                                                                                                        
}.                                                                                                                   
                                                                                                                     
//This will be our main control loop for the ascent. It will                                                         
//cycle through continuously until our apoapsis is greater                                                           
//than 100km. Each cycle, it will check each of the IF                                                               
//statements inside and perform them if their conditions                                                             
//are met
set mysteer_angle to 90.
SET MYSTEER TO HEADING(90,mysteer_angle).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER   
UNTIL SHIP:APOAPSIS > 100000 {
    
    set mysteer_angle to - (SHIP:VELOCITY:SURFACE:MAG * SHIP:VELOCITY:SURFACE:MAG) / 5000 + 90.
    if mysteer_angle<10 {
	set mysteer_angle to 10.
    }
    SET MYSTEER TO HEADING(90,mysteer_angle).
    
    //log
    if time-session_start>1{
        set session_start to time.
        set data_values to list().
        data_values:add(time).
        data_values:add(ship:latitude).
        data_values:add(ship:longitude).
        data_values:add(ship:altitude).
        data_values:add(ship:velocity:surface:x).
        data_values:add(ship:velocity:surface:y).
        data_values:add(ship:velocity:surface:z).
        data_values:add(ship:velocity:orbit:x).
        data_values:add(ship:velocity:orbit:y).
        data_values:add(ship:velocity:orbit:z).
        data_values:add(ship:body:mass).
	data_values:add(SHIP:APOAPSIS).
	data_values:add(SHIP:VELOCITY:SURFACE:MAG).
	data_values:add(mysteer_angle).
        WRITEJSON(data_values, "1:/log"+session_step+".json").
        movepath("1:/log"+session_step+".json", "0:/logs/").
        set session_step to session_step+1.
        print mysteer_angle.
    }        

}.

//PRINT "100km apoapsis reached, cutting throttle".
PRINT "cutting throttle".

//At this point, our apoapsis is above 100km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
LOCK THROTTLE TO 0.

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
