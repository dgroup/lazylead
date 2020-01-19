###Trello Development guide

**Enable integration requsites**\
Before start testing integration with Trello you need to retrieve *API key* and *API token* from Trello by following link https://developers.trello.com/page/authorization

**Environment Variables**\
To run tests with integration to Trello you have to setup following environment variables:

Varable|Description
--- | --- 
|*TRELLO_BOARD*| your existing board in Trello
|*TRELLO_KEY* | your API key
|*TRELLO_TOKEN*|you API token

Example:
```bash
mvn -P quilice clean install -DTRELLO_KEY={TRELLO_KEY} -DTRELLO_TOKEN={TRELLO_TOKEN} -DTRELLO_BOARD={TRELLO_BOARD}
```
