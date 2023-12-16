# README

## Description
This app shows the user their current location on a map. It also shows the user's ride history.

## BUGS
There is a known bug (warning) with a decsription:
    
    *This method can cause UI unresponsiveness if invoked on the main thread. 
    Instead, consider waiting for the `-locationManagerDidChangeAuthorization:` 
    callback and checking `authorizationStatus` first.*

I was unable to, due to the fact that I'm working with time, find the solution to the warning. 
The warning however does not affect the app's performance.

## Author
Daniel Eze

## Date
DEC 15
