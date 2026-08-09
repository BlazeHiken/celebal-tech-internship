import unittest
from datetime import datetime, timedelta

# Functions simulating system validation logic to handle edge cases

def check_order_items_referential_integrity(order_items, valid_order_ids):
    """Finds items that reference non-existent orders."""
    invalid_items = [item for item in order_items if item['order_id'] not in valid_order_ids]
    return invalid_items

def validate_discount(discount_percent):
    """Validates if discount is between 0 and 100."""
    if discount_percent < 0 or discount_percent > 100:
        raise ValueError(f"Invalid discount percent: {discount_percent}. Must be between 0 and 100.")
    return True

def validate_quantity(quantity):
    """Validates if quantity is non-zero (can be negative for returns, positive for purchases)."""
    if quantity == 0:
        raise ValueError("Quantity cannot be 0.")
    return True

def validate_order_date(order_date_str):
    """Validates if order date is not in the future."""
    # Assuming order_date_str is 'YYYY-MM-DD HH:MM:SS'
    order_date = datetime.strptime(order_date_str, "%Y-%m-%d %H:%M:%S")
    if order_date > datetime.now():
        raise ValueError(f"Order date {order_date_str} cannot be in the future.")
    return True

class TestEdgeCases(unittest.TestCase):
    
    def test_invalid_order_id_in_order_items(self):
        """1. What happens when order_items has an order_id not in orders?"""
        valid_order_ids = {'ORD_1', 'ORD_2'}
        order_items = [
            {'item_id': 'I1', 'order_id': 'ORD_1'},
            {'item_id': 'I2', 'order_id': 'ORD_INVALID'}
        ]
        
        # System should identify the invalid item
        invalid_items = check_order_items_referential_integrity(order_items, valid_order_ids)
        
        self.assertEqual(len(invalid_items), 1)
        self.assertEqual(invalid_items[0]['item_id'], 'I2')

    def test_discount_percent_gt_100(self):
        """2. What happens when discount_percent > 100?"""
        # System should throw an error or reject the data
        with self.assertRaises(ValueError) as context:
            validate_discount(150)
        self.assertTrue('Must be between 0 and 100' in str(context.exception))

    def test_quantity_is_zero(self):
        """3. What happens when quantity is 0?"""
        # System should throw an error as quantity 0 is meaningless for an order item
        with self.assertRaises(ValueError) as context:
            validate_quantity(0)
        self.assertEqual(str(context.exception), "Quantity cannot be 0.")

    def test_order_date_in_future(self):
        """4. What happens when order_date is in the future?"""
        # System should reject future dates
        future_date = (datetime.now() + timedelta(days=5)).strftime("%Y-%m-%d %H:%M:%S")
        with self.assertRaises(ValueError) as context:
            validate_order_date(future_date)
        self.assertTrue('cannot be in the future' in str(context.exception))

if __name__ == '__main__':
    unittest.main()
