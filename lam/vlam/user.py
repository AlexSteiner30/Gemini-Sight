import browser
import keras

"""
prompt text -> action|url
model process action -> taks1|task2|task3

for task in tasks:
    open url -> screenshot|task
    model process task -> selenium|processed_task
"""

class User:
    def __init__(self, authentication_key) -> None:
        self.authentication_key = authentication_key
        self.chat = []
        pass

    def add_chat(self, user, message):
        self.chat.append({'user':user, 'message':message})