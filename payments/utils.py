import logging
from forex_python.converter import CurrencyRates # https://github.com/MicroPyramid/forex-python
from dndsos.models import ContactUs, AdminParameters

logger = logging.getLogger(__file__)

def getRates():
    try:
        c = CurrencyRates()
        usd_ils = c.get_rate('USD', 'ILS')
        usd_eur = c.get_rate('USD', 'EUR')
    except Exception as e:
        print(f'>> PAYMENTS UTILS: Failed to getting currencies from CurrencyRates model. ERROR: {e}')
        logger.error(f'>> PAYMENTS UTILS: Failed to getting currencies from CurrencyRates model. Setting defaults. ERROR: {e}')
        try:
            admin_params = AdminParameters.objects.all().first()
            usd_ils = admin_params.usd_ils_default
            usd_eur = admin_params.usd_eur_default
        except Exception as e:
            print(f'>> PAYMENTS UTILS: Failed to load default currencies. ERROR: {e}')
            logger.error(f'>> PAYMENTS UTILS: Failed to load currencies. Setting defaults. ERROR: {e}')
            usd_ils = 3.5
            usd_eur = 0.8
    
    return usd_ils, usd_eur