# LAM - Large Action Model

This model is still under early development, this model in a near future should integrate with the Gemini API in order for a user to be able to navigative any website my speech command, for example ordering a door dash.

## How it Works

prompt text -> action|url
model process action -> taks1|task2|task3

for task in tasks:
    open url -> screenshot|task
    model process task -> selenium|processed_task