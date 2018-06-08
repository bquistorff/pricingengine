import os
import datetime
import numpy as np
import matplotlib.pyplot as plt

from pricingengine import *
import oj_demand_modeling

data_loc = os.path.dirname(os.path.dirname(__file__)) + '/data/'
dataset = oj_demand_modeling.load_dataset(data_loc)

training_data = dataset.filter(last_date=datetime.datetime(2002, 1, 1))
model = oj_demand_modeling.train_model(training_data)

baseline_scenario = dataset.filter(first_date=datetime.datetime(2001, 9, 1),
                              last_date=datetime.datetime(2002, 3, 1),
                              filter_dic={'store id' : ['100']})



promo_scenario = baseline_scenario.append_data_one_instance(panel_dic={'store id' : '100', 'brand' : 'tropicana'},
                                                          treatments_path={'log price' : [np.log(x) for x in [2]]},
                                                          start_date=datetime.datetime(2002, 1, 12))

base_pred = model.predict(baseline_scenario, outcome_is_log=True).get_projections_from_date(datetime.datetime(2002, 1, 5), coverage=.9).reset_index()
promo_pred = model.predict(promo_scenario, outcome_is_log=True).get_projections_from_date(datetime.datetime(2002, 1, 5), coverage=.9).reset_index()

plt.close()
plt.plot(base_pred.loc[base_pred['brand'] == 'tropicana', 'week'],
         base_pred.loc[base_pred['brand'] == 'tropicana', 'prediction'], 'ro-',
         label='Tropicana Base')
plt.plot(promo_pred.loc[promo_pred['brand'] == 'tropicana', 'week'],
         promo_pred.loc[promo_pred['brand'] == 'tropicana', 'prediction'], 'ro--',
         label='Tropicana Promo')

plt.plot(base_pred.loc[base_pred['brand'] == 'minute.maid', 'week'],
         base_pred.loc[base_pred['brand'] == 'minute.maid', 'prediction'], 'bv-',
         label='Minute Maid Base')
plt.plot(promo_pred.loc[promo_pred['brand'] == 'minute.maid', 'week'],
         promo_pred.loc[promo_pred['brand'] == 'minute.maid', 'prediction'], 'bv--',
         label='Minute Maid Promo')

plt.plot(base_pred.loc[base_pred['brand'] == 'dominicks', 'week'],
         base_pred.loc[base_pred['brand'] == 'dominicks', 'prediction'], 'gx-',
         label='Dominicks Base')
plt.plot(promo_pred.loc[promo_pred['brand'] == 'dominicks', 'week'],
         promo_pred.loc[promo_pred['brand'] == 'dominicks', 'prediction'], 'gx--',
         label='Dominicks Promo')
plt.legend()
plt.show()


mfx = model.get_marginal_effects('log price', 'brand', filter_dic={'store id' : ['100']})
print(mfx.mfx)