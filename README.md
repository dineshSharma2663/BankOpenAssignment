# BankOpenTask
This project show schedules of buses running in the city. In this we fetch data from project JSON file & saving that in core data. & controller initiates timer to refresh bus schedule every one minute. Data base request protocol defines databases query methods used by view model to load data from data base & View Model protocol defines method which are called from view class to fetch displayable data. as soon as routeDisplayable is update in view model, we call refresh UI in view controller class to update UI

## Assumption
For this, i have read data from local json file & assumed date format as 'HH:mm'. There may be a case when no data is visible for any route. 
We can just make some changes in json file & update some trip timings after current time. then we will can see those trip timings.
I have assumed there is no need to refresh app in background hence, we are stopping timer when app goes in back ground
But as soon as we are making fresh refresh & starting timer as well.


## Design Pattern
- MVVM Structural Design Pattern
- Protocol Oriented Programming
- Bus schedule is divided into 4 layers
- View Model - returns data model of Displayable protocol
- View 
- Controller
- Displayable Models

## Flexibility
- View & View Controller has no direct depending on Core Data hence we can use different data base at any time with minimum changes
- View Formatter is handled in Displayable Data Model hence whole view formatting can be done from one place
- Instead of reading data from json file, we can make api call as well.


## Database:
CoreData
RouteInfo & TripTiming Entities
Core Data and persistent storage, by reading schedule data from both, locally and remotely retrieved [JSON file /  response] We creates and stores those records in a SQLite datastore. It is possible to do single and batch updates, deletions, retrieving and filtering on routes via Date & routeId


## [TechStack]
Swift5.0
Minimum iOS10 Deployment Target

## Features:
- Portrait + Landscape
- Dark Mode Support iOS 13 later on
- Dynamic Font
- Internalisation
