from selenium import webdriver

browser = webdriver.Firefox()

def open_website(url):
    try:
        browser.get(url)
    except:
        pass