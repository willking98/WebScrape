from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time

drugs = ["anastrazole", "amoxicillin", "ibuprofen", "flucloxacillin", "hiprex", "penicilin", "diamox", "codiene", "cefalexin"]
driver = webdriver.Chrome(executable_path=r'/Users/Will/Downloads/chromedriver')
driver.get('https://bnf.nice.org.uk/')

search = driver.find_element_by_name("q")


for i in drugs:
    search.click()
    search.send_keys(Keys.BACK_SPACE)
    search.send_keys(i)
    search.send_keys(Keys.ENTER)
    time.sleep(2)

driver.quit()


# Copy xpath using chrome: "//*[@id='search-results']/div[1]/div[2]/ul/li[2]/div/h4/a"

# Within the for loop I need to click on each link with medicinal forms in title of link
