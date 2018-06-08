import os
import datetime

from pricingengine import *
import oj_demand_modeling

data_loc = os.path.dirname(os.path.dirname(__file__)) + '/data/'
dataset = oj_demand_modeling.load_dataset(data_loc)

training_data = dataset.filter(last_date=datetime.datetime(2002, 1, 1))
training_data_sub = dataset.filter(last_date=datetime.datetime(2002, 1, 1), filter_dic={'store id' : ['99', '100']})
testing_data = dataset.filter(first_date=datetime.datetime(2002, 1, 8), filter_dic={'store id' : ['99', '100']})

#get smapes from large model
model_all = oj_demand_modeling.train_model(training_data)
pred_all = model_all.predict(testing_data, outcome_is_log=True)
print(pred_all.get_smape(names=['store id']))

##Get smapes from small model
#model_sub = oj_demand_modeling.train_model(training_data_sub)
#pred_sub = model_sub.predict(testing_data, outcome_is_log=True)
#print(pred_sub.get_smape(names=['store id']))