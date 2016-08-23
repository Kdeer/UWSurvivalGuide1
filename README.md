# UWSurvivalGuide1
The final self-decide project from Udacity

UWSurvivalGuide is made based on the API from University of Waterloo.
There are 4 sections, which are News, Events, Parking and Food.

![f3ee4a4c-2da8-493b-aca2-3ed25abcfa06](https://cloud.githubusercontent.com/assets/16344019/17907145/6cb1517e-6948-11e6-8c33-8ed3e5163176.png)
![14c4e23c-1af0-4e79-bd91-cfd92c32f94f](https://cloud.githubusercontent.com/assets/16344019/17907156/75b55cfc-6948-11e6-8c28-888e6ef58567.png)


##In News section, users can:

1. View news in list style, where each page has 5 news with News title, news image(if there is one, otherwise the campus bubble will replace it's position), and a short beginning words from tne news.
2. click the next page or previous page to change the page, or enter the page they want to go.
3. After entering a news, the time of the news being published and updated will show up. And of course the news itself. The full size image too.
4. The News section has self-refresh function. After user quit the app after 3 hours, the News section will refresh itself when users go back to the app.

##In Events section, users can:

1. see all the events posted by University of Waterloo, either on campus or off campus. In the lists, only event type, name and time are included.
2. when user select an event, the event description will show up too.
3. If users think the event's info is not sufficient, they can click the link button to see the original link on safari.
4. There is a location button to help user to find the location on map.
5. If users are interested in some events, they can click the "star" button to put it into the ExpectedEvent list. the expected event will have yellow star among all the event list.
6. The event list is also searchable.
7. If the expected event is expired, a red label "Expired" will show up at the table view.


##In Parking section, users can:

1. see 5 sections, Monitored, Visitor, Permit, meter and Building.
2. In Monitored section, there are 4 parking spots with real date available. This section is applied by KDCircularProgress view on these 4 parking spots. User can refresh the data by select the Refresh button.
3. User can also select the parking spot to see it on the map. 
4. The Visitor, Permit, Meter and Building are all table view controllers. Users can accesss the parking information in these table view controller.
5. At the top right side, there is a "Direction" kind like button, users will see all the parking spots all the mapView with parking styles.

6. Food Section,

1. The first screen users will see is all the Food outlets with name image on a table view.
2. After select one outlet, extra information will show up in an view controller including building, description, direction button, open hours, and Service.
3. Right now only two outlets have menu available, I wish University of Waterloo will update its API so users can see the menus from all outlets.(let's just hope)


There are also some extra features not mentioned in ReadMe, you are welcome to explore it by yourself and please let me if there is a bug or something not working appropriate.




Cheers!

Zack

