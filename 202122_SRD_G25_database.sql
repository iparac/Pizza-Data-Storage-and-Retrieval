-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema dataretrieval
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `dataretrieval` ;

-- -----------------------------------------------------
-- Schema dataretrieval
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `dataretrieval` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `dataretrieval` ;

-- -----------------------------------------------------
-- Table `dataretrieval`.`allergen`
-- -----------------------------------------------------
-- Contains allergen names
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`allergen` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`allergen` (
  `allergen_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(75) NOT NULL,
  PRIMARY KEY (`allergen_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `dataretrieval`.`postal_code`
-- -----------------------------------------------------
-- Contains postal_codes and names of cities
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`postal_code` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`postal_code` (
  `postal_code_id` INT NOT NULL AUTO_INCREMENT,
  `postal_code` VARCHAR(45) NOT NULL,
  `city` VARCHAR(145) NOT NULL,
  PRIMARY KEY (`postal_code_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`customer`
-- -----------------------------------------------------
-- Contains information about the customer
-- Information is inputed when user registers in the application
-- If customer is eating in the restaurant, customer_taxpayer_id, postal_code_id, first_name and last_name are pulled when the customer gives his NIF (tax number)
-- Fields that allow NULL are only filled in when customers registers via the application
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`customer` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`customer` (
  `customer_taxpayer_id` INT NOT NULL,
  `postal_code_id` INT NOT NULL,
  `first_name` VARCHAR(70) NOT NULL,
  `last_name` VARCHAR(85) NOT NULL,
  `contact_number` VARCHAR(50) NULL DEFAULT NULL,
  `email` VARCHAR(75) NULL DEFAULT NULL,
  `street_address` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`customer_taxpayer_id`),
  CONSTRAINT `fk_customer_postal_code1`
    FOREIGN KEY (`postal_code_id`)
    REFERENCES `dataretrieval`.`postal_code` (`postal_code_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_customer_postal_code1_idx` ON `dataretrieval`.`customer` (`postal_code_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`restaurant`
-- -----------------------------------------------------
-- Contains information about all the restaurants
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`restaurant` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`restaurant` (
  `restaurant_id` INT NOT NULL AUTO_INCREMENT,
  `postal_code_id` INT NOT NULL,
  `restaurant_name` VARCHAR(200) NOT NULL,
  `street_address` VARCHAR(100) NOT NULL,
  `contact_number` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`restaurant_id`),
  CONSTRAINT `fk_restaurant_postal_code1`
    FOREIGN KEY (`postal_code_id`)
    REFERENCES `dataretrieval`.`postal_code` (`postal_code_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_restaurant_postal_code1_idx` ON `dataretrieval`.`restaurant` (`postal_code_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`order_type`
-- -----------------------------------------------------
-- Order type can be: delivery, eating-in and pick-up
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`order_type` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`order_type` (
  `order_type_id` INT NOT NULL AUTO_INCREMENT,
  `order_type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`order_type_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `dataretrieval`.`payment_option`
-- -----------------------------------------------------
-- Payment options are: cash, mb way, card...
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`payment_option` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`payment_option` (
  `payment_option_id` INT NOT NULL AUTO_INCREMENT,
  `payment_option` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`payment_option_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `dataretrieval`.`delivery_company`
-- -----------------------------------------------------
-- Door dash companies that restaurants outsource the deliveries to
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`delivery_company` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`delivery_company` (
  `delivery_company_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `contact_number` VARCHAR(50) NOT NULL,
  `city` VARCHAR(145) NOT NULL,
  `email` VARCHAR(75) NOT NULL,
  PRIMARY KEY (`delivery_company_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`order`
-- -----------------------------------------------------
-- One of the most important tables since it is used for the customers order
-- total_price is calculated using triggers and is constantly updated when the item is added
-- rating can be NULL since it isn't necessary to always rate the order
-- rating is updated using trigger, since restaurant can only be rated after the customer paid and got their food
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`order` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`order` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `order_type_id` INT NOT NULL,
  `restaurant_id` INT NOT NULL,
  `payment_option_id` INT NOT NULL,
  `delivery_company_id` INT NULL DEFAULT NULL,
  `customer_taxpayer_id` INT NULL DEFAULT NULL,
  `employee_taxpayer_id` INT NULL DEFAULT NULL,
  `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_price` DECIMAL(20,2) NOT NULL,
  `order_comment` VARCHAR(100) NULL DEFAULT NULL,
  `rating` INT NULL DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  CONSTRAINT `customer_order_ibfk_1`
    FOREIGN KEY (`customer_taxpayer_id`)
    REFERENCES `dataretrieval`.`customer` (`customer_taxpayer_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `customer_order_ibfk_2`
    FOREIGN KEY (`restaurant_id`)
    REFERENCES `dataretrieval`.`restaurant` (`restaurant_id`)
    ON UPDATE CASCADE,
  CONSTRAINT `fk_customer_order_order_type1`
    FOREIGN KEY (`order_type_id`)
    REFERENCES `dataretrieval`.`order_type` (`order_type_id`)
    ON UPDATE CASCADE,
  CONSTRAINT `fk_customer_order_payment_option1`
    FOREIGN KEY (`payment_option_id`)
    REFERENCES `dataretrieval`.`payment_option` (`payment_option_id`)
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_delivery_company1`
    FOREIGN KEY (`delivery_company_id`)
    REFERENCES `dataretrieval`.`delivery_company` (`delivery_company_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `order_employee_fk`
    FOREIGN KEY (`employee_taxpayer_id`)
    REFERENCES `dataretrieval`.`employee` (`employee_taxpayer_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `customer_id` ON `dataretrieval`.`order` (`customer_taxpayer_id` ASC) VISIBLE;

CREATE INDEX `employee_id` ON `dataretrieval`.`order` (`employee_taxpayer_id` ASC) VISIBLE;

CREATE INDEX `restaurant_id` ON `dataretrieval`.`order` (`restaurant_id` ASC) VISIBLE;

CREATE INDEX `fk_customer_order_order_type1_idx` ON `dataretrieval`.`order` (`order_type_id` ASC) VISIBLE;

CREATE INDEX `fk_customer_order_payment_option1_idx` ON `dataretrieval`.`order` (`payment_option_id` ASC) VISIBLE;

CREATE INDEX `fk_order_delivery_company1_idx` ON `dataretrieval`.`order` (`delivery_company_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`bank_account`
-- -----------------------------------------------------
-- List of employee bank accounts for paying them their salaries
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`bank_account` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`bank_account` (
  `bank_account_id` INT NOT NULL AUTO_INCREMENT,
  `bank_account` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`bank_account_id`))
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `dataretrieval`.`job`
-- -----------------------------------------------------
-- List of jobs that exist in the restaurant
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`job` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`job` (
  `job_id` INT NOT NULL AUTO_INCREMENT,
  `job_title` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`job_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`employee`
-- -----------------------------------------------------
-- Information about all the employees that work in the restaurants
-- superior_id is a unary 1:N key that allows NULL, which means that every employee can, but doesn't have to have a superior
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`employee` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`employee` (
  `employee_taxpayer_id` INT NOT NULL,
  `bank_account_id` INT NOT NULL,
  `restaurant_id` INT NOT NULL,
  `postal_code_id` INT NOT NULL,
  `job_id` INT NOT NULL,
  `superior_id` INT NULL DEFAULT NULL,
  `first_name` VARCHAR(70) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `street_address` VARCHAR(100) NOT NULL,
  `contact_number` VARCHAR(50) NOT NULL,
  `salary` DECIMAL(20,2) NOT NULL,
  PRIMARY KEY (`employee_taxpayer_id`),
  CONSTRAINT `employee_ibfk_1`
    FOREIGN KEY (`restaurant_id`)
    REFERENCES `dataretrieval`.`restaurant` (`restaurant_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_employee_employee1`
    FOREIGN KEY (`superior_id`)
    REFERENCES `dataretrieval`.`employee` (`employee_taxpayer_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_employee_bank_account1`
    FOREIGN KEY (`bank_account_id`)
    REFERENCES `dataretrieval`.`bank_account` (`bank_account_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_postal_code1`
    FOREIGN KEY (`postal_code_id`)
    REFERENCES `dataretrieval`.`postal_code` (`postal_code_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_job1`
    FOREIGN KEY (`job_id`)
    REFERENCES `dataretrieval`.`job` (`job_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `restaurant_id` ON `dataretrieval`.`employee` (`restaurant_id` ASC) VISIBLE;

CREATE INDEX `fk_employee_employee1_idx` ON `dataretrieval`.`employee` (`superior_id` ASC) VISIBLE;

CREATE INDEX `fk_employee_bank_account1_idx` ON `dataretrieval`.`employee` (`bank_account_id` ASC) VISIBLE;

CREATE INDEX `fk_employee_postal_code1_idx` ON `dataretrieval`.`employee` (`postal_code_id` ASC) VISIBLE;

CREATE INDEX `fk_employee_job1_idx` ON `dataretrieval`.`job` (`job_id` ASC) VISIBLE;

CREATE INDEX `employee_id` ON `dataretrieval`.`employee` (`employee_taxpayer_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`shift`
-- -----------------------------------------------------
-- List of all shifts in the restaurants
-- There are two possible shifts, morning and evening, so if morning = 0 it means that it is a evening shift
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`shift` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`shift` (
  `shift_id` INT NOT NULL AUTO_INCREMENT,
  `shift_date` DATE NOT NULL,
  `morning` TINYINT(1) NOT NULL,
  PRIMARY KEY (`shift_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `dataretrieval`.`employee_has_shift`
-- -----------------------------------------------------
-- N:M relationship which means that each employee can have multiple shifts, and each shift can have multiple employees
-- manager = 1 means that the employee is in charge of the shift
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`employee_has_shift` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`employee_has_shift` (
  `employee_taxpayer_id` INT NOT NULL,
  `shift_id` INT NOT NULL,
  `manager` TINYINT(1) NOT NULL,
  PRIMARY KEY (`employee_taxpayer_id`, `shift_id`),
  CONSTRAINT `fk_shift_has_employee_employee1`
    FOREIGN KEY (`employee_taxpayer_id`)
    REFERENCES `dataretrieval`.`employee` (`employee_taxpayer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_shift_has_employee_shift1`
    FOREIGN KEY (`shift_id`)
    REFERENCES `dataretrieval`.`shift` (`shift_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_shift_has_employee_employee1_idx` ON `dataretrieval`.`employee_has_shift` (`employee_taxpayer_id` ASC) VISIBLE;

CREATE INDEX `fk_shift_has_employee_shift1_idx` ON `dataretrieval`.`employee_has_shift` (`shift_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`measurement`
-- -----------------------------------------------------
-- List of mesurments like: kilogram, liter, item, ounce etc..
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`measurement` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`measurement` (
  `measurement_id` INT NOT NULL AUTO_INCREMENT,
  `measurement` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`measurement_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `dataretrieval`.`ingredient`
-- -----------------------------------------------------
-- Contains all the ingredients that the restaurant requires for the menu
-- Used for keeping track of the quantities of the igredients in the storage 
-- Triggers would be used to deduct the required quantity from each of the ingredients when a order is made
-- When ingredient falls below the set threshold, a alert would be made to restock
-- Allergen can be NULL
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`ingredient` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`ingredient` (
  `ingredient_id` INT NOT NULL AUTO_INCREMENT,
  `measurement_id` INT NOT NULL,
  `allergen_id` INT NULL DEFAULT NULL,
  `name` VARCHAR(70) NOT NULL,
  `quantity` DECIMAL(10,5) NOT NULL,
  PRIMARY KEY (`ingredient_id`),
  CONSTRAINT `fk_ingredient_allergen1`
    FOREIGN KEY (`allergen_id`)
    REFERENCES `dataretrieval`.`allergen` (`allergen_id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ingredient_measurement1`
    FOREIGN KEY (`measurement_id`)
    REFERENCES `dataretrieval`.`measurement` (`measurement_id`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_ingredient_allergen1_idx` ON `dataretrieval`.`ingredient` (`allergen_id` ASC) VISIBLE;

CREATE INDEX `fk_ingredient_measurement1_idx` ON `dataretrieval`.`ingredient` (`measurement_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`log`
-- -----------------------------------------------------
-- Used for logging the changes to the database (INSERT, DELETE, UPDATE), and the time of the changes
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`log` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`log` (
  `log_id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `row` INT NOT NULL,
  `table` VARCHAR(35) NULL DEFAULT NULL,
  `change_type` VARCHAR(25) NULL DEFAULT NULL,
  PRIMARY KEY (`log_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `dataretrieval`.`price`
-- -----------------------------------------------------
-- List of base prices for items
-- It is done this way so that when combined with the table price_modifier, discounts can be calculted in a trigger by multiplying with the base price
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`price` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`price` (
  `price_id` INT NOT NULL AUTO_INCREMENT,
  `base_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`price_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`price_modifier`
-- -----------------------------------------------------
-- Represents discounts and modifiers for size increases (S, M, L...)
-- In the case of no discount price_modifier can be 1
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`price_modifier` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`price_modifier` (
  `price_modifier_id` INT NOT NULL AUTO_INCREMENT,
  `price_modifier` DECIMAL(10,5) NOT NULL,
  PRIMARY KEY (`price_modifier_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`size`
-- -----------------------------------------------------
-- List of sizes of items
-- Could range from small, medium, large to 1l, 0.5l, 0.3l
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`size` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`size` (
  `size_id` INT NOT NULL AUTO_INCREMENT,
  `size` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`size_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`item`
-- -----------------------------------------------------
-- Items that customer can order which are then added to the order
-- price is calculated with the price_id and price_modifier_id
-- column units in the case of ordering same item multiple times
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`item` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`item` (
  `item_id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `price_id` INT NOT NULL,
  `price_modifier_id` INT NOT NULL,
  `size_id` INT NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `units` INT NOT NULL,
  PRIMARY KEY (`item_id`),
  CONSTRAINT `pizza_ibfk_1`
    FOREIGN KEY (`order_id`)
    REFERENCES `dataretrieval`.`order` (`order_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_item_price1`
    FOREIGN KEY (`price_id`)
    REFERENCES `dataretrieval`.`price` (`price_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_item_price_modifier1`
    FOREIGN KEY (`price_modifier_id`)
    REFERENCES `dataretrieval`.`price_modifier` (`price_modifier_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_item_size1`
    FOREIGN KEY (`size_id`)
    REFERENCES `dataretrieval`.`size` (`size_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `order_id` ON `dataretrieval`.`item` (`order_id` ASC) VISIBLE;

CREATE INDEX `fk_item_price1_idx` ON `dataretrieval`.`item` (`price_id` ASC) VISIBLE;

CREATE INDEX `fk_item_price_modifier1_idx` ON `dataretrieval`.`item` (`price_modifier_id` ASC) VISIBLE;

CREATE INDEX `fk_item_size1_idx` ON `dataretrieval`.`item` (`size_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`driver`
-- -----------------------------------------------------
-- Information about the drivers in the delivery companies
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`driver` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`driver` (
  `driver_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(70) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `contact_number` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`driver_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `dataretrieval`.`delivery_company_has_driver`
-- -----------------------------------------------------
-- N:M relationship that means that each driver can work for more companies at the same time
-- For example (Glovo, Bolt Eats and Uber eats) and taking the closest deliveries
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`delivery_company_has_driver` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`delivery_company_has_driver` (
  `delivery_company_id` INT NOT NULL,
  `driver_id` INT NOT NULL,
  PRIMARY KEY (`delivery_company_id`, `driver_id`),
  CONSTRAINT `fk_driver_has_delivery_company_driver1`
    FOREIGN KEY (`driver_id`)
    REFERENCES `dataretrieval`.`driver` (`driver_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_driver_has_delivery_company_delivery_company1`
    FOREIGN KEY (`delivery_company_id`)
    REFERENCES `dataretrieval`.`delivery_company` (`delivery_company_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_driver_has_delivery_company_delivery_company1_idx` ON `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id` ASC) VISIBLE;

CREATE INDEX `fk_driver_has_delivery_company_driver1_idx` ON `dataretrieval`.`delivery_company_has_driver` (`driver_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `dataretrieval`.`item_has_ingredient`
-- -----------------------------------------------------
-- N:M relationship that means that each item consists of M ingredients
-- -----------------------------------------------------
DROP TABLE IF EXISTS `dataretrieval`.`item_has_ingredient` ;

CREATE TABLE IF NOT EXISTS `dataretrieval`.`item_has_ingredient` (
  `item_id` INT NOT NULL,
  `ingredient_id` INT NOT NULL,
  PRIMARY KEY (`item_id`, `ingredient_id`),
  CONSTRAINT `fk_ingredient_has_item_ingredient1`
    FOREIGN KEY (`ingredient_id`)
    REFERENCES `dataretrieval`.`ingredient` (`ingredient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ingredient_has_item_item1`
    FOREIGN KEY (`item_id`)
    REFERENCES `dataretrieval`.`item` (`item_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_ingredient_has_item_item1_idx` ON `dataretrieval`.`item_has_ingredient` (`item_id` ASC) VISIBLE;

CREATE INDEX `fk_ingredient_has_item_ingredient1_idx` ON `dataretrieval`.`item_has_ingredient` (`ingredient_id` ASC) VISIBLE;



-- -----------------------------------------------------
-- ----------------------TRIGGERS-----------------------
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Trigger insert order into log table
-- -----------------------------------------------------
-- Trigger inserts a new row into log table after new order is made
-- log_id is auto_increment so DEFAULT values are always added
-- timestamp is time when the change was being made (item being ordered) so that is also DEFAULT
-- table is the name of the table on which insert happened (in this case it is always table order)
-- change_type is INSERT / DELETE / UPDATE (in this case it is always INSERT so it is hard-coded)
-- row is new order_id
-- -----------------------------------------------------
DELIMITER $$
USE `dataretrieval`$$
CREATE
DEFINER=`root`@`localhost`
trigger log_insert_order
after insert on `order`
for each row
begin
	INSERT INTO `dataretrieval`.`log` (`log_id`, `timestamp`, `table`, `change_type`, `row`) 
    VALUES (DEFAULT, DEFAULT, 'order', 'INSERT', new.order_id);
 end$$
delimiter ;



-- -----------------------------------------------------
-- Trigger total_order_cost
-- -----------------------------------------------------
-- Trigger adds up all item prices when they are being added to the order
-- Three new variables are declared: temp_price (base_price from table price), modifier (price_modifier from table price_modifier), and num_units (units from table items)
-- Then total_price column from table item is being updated
-- Value of the total_price column is calculated like: total_price = total_price + ((temp_price * modifier) * num_units)
-- Every time new item is added, total_price is calculated and order.total_price is UPDATED
-- This works only when adding items, and does not work when trying to remove items (another trigger would be used or this one improved)
-- -----------------------------------------------------
DELIMITER $$
USE `dataretrieval`$$
CREATE
DEFINER=`root`@`localhost`
trigger total_order_cost
after insert on item
for each row
begin
	DECLARE temp_price decimal(10,2);
    DECLARE modifier decimal(10,5);
    DECLARE num_units int;
    
    SELECT price.base_price 
    FROM price 
    WHERE new.price_id = price.price_id
    INTO temp_price;
	
    SELECT price_modifier.price_modifier 
    FROM price_modifier 
    WHERE new.price_modifier_id = price_modifier.price_modifier_id
    INTO modifier;
    
	SELECT item.units
    FROM item 
    WHERE new.item_id = item.item_id
    INTO num_units;
    
    UPDATE `order`
    SET total_price = total_price + ((temp_price * modifier) * num_units)
    WHERE `order`.order_id = new.order_id;
 end$$
delimiter ;








-- -----------------------------------------------------
-- DATA GENERATION FOR ALL THE TABLES (20+ ROWS EACH WHERE IT WAS POSSIBLE)
-- -----------------------------------------------------


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;




-- -----------------------------------------------------
-- Data for table `dataretrieval`.`postal_code`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '1000', 'Lisbon');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '4000', 'Porto');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '3800', 'Aveiro');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '7800', 'Beja');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '4700', 'Braga');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '5300', 'Braganca');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '6000', 'Castelo Branco:');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '3000', 'Coimbra');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '7000', 'Evora');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '8000', 'Faro');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '9000', 'Funchal');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '6300', 'Guarda');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '2400', 'Leiria');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '9500', 'Ponta Delgada');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '7300', 'Portalegre');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '2000', 'Santarem');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '2900', 'Setubal');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '4900', 'Viana do Castelo');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '5000', 'Vila Real');
INSERT INTO `dataretrieval`.`postal_code` (`postal_code_id`, `postal_code`, `city`) VALUES (DEFAULT, '3500', 'Viseu');

COMMIT;





-- -----------------------------------------------------
-- Data for table `dataretrieval`.`customer`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (654367807, 1, 'Nadia','Berry', '815-834-6405', 'nadiaberry@gmail.com', '1631 Counts Lane');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (793134894, 2, 'Logan','Berry', '646-572-1194', 'loganberry@gmail.com', '570 Saint Francis Way');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (833799495, 3, 'Santiago','Campbell', '580-940-8116','santiagocampbell@gmail.com', '2731 Hedge Street');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (212246218, 4, 'Meredith','Okley', '715-880-5692','meredithokley@gmail.com', '3969 Adonais Way');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (806952487, 5, 'Warda','Hazael', '843-720-4190','wardahazael@gmail.com', '2474 Prudence Street');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (414203373, 6, 'Flaviano','Perceval', '310-546-3185','flavianoperceval@gmail.com', '4778 Lawman Avenue');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (759028675, 1, 'Leucippus','Pwyll', '508-925-2769','leucippuspwyll@gmail.com', '3751 Lakeland Park Drive');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (370475397, 1, 'Kiera','Pericles', '530-876-5372','kierapericles@gmail.com', '2751 McDonald Avenue');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (737944719, 1, 'Casandra','Egbert','972-321-7779','casandraegbert@gmail.com', '2395 Levy Court');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (969601927, 2, 'Nazaire','Aleksandar', '701-361-9747','nazairealeksandar@gmail.com', '4848 Libby Street');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (917376445, 3, 'Dip','Ahava', '215-587-8534','dipahava@gmail.com', '4727 Sardis Sta');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (565027607, 2, 'Fyokla','Vanesa', '603-504-2366','fyoklavanesa@gmail.com', '2835 Oak Drive');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (480262759, 13, 'Anne','Sukarno', '405-722-5578','annesukarno@gmail.com', '3751 Kildeer Drive');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (981827306, 11, 'Hroderich','Baldovin', '908-763-6549', 'hroderichbaldovin@gmail.com', '4687 Poe Lane');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (780431395, 15, 'Thanasis','Amalasuintha', '708-987-2188','thanasisamalasuitntha@gmail.com', '1501 Watson Street');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (461804237, 17, 'Frøya','Meshach', '602-268-4501','froyameshach@gmail.com', '4971 Yorkie Lane');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (399220897, 19, 'Dipika','Lo', '615-393-3712', 'dipikalo@gmail.com','576 Wines Lane');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (942604591, 6, 'Blandus','Eija','309-551-4503','blanduseija@gmail.com', '5001 Atha Drive');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (346777180, 7, 'Aetius','Igor','479-508-9705','aetiusigor@gmail.com','2077 Paradise Lane');
INSERT INTO `dataretrieval`.`customer` (`customer_taxpayer_id`, `postal_code_id`, `first_name`, `last_name`, `contact_number`, `email`, `street_address`) VALUES (308309888, 1, 'Brynhild','Silvia', '330-759-6340','brynhildsilvia@gmail.com', '511 Formula Lane');

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`restaurant`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 1, 'CASA NEPALESA', 'Rua do Paco 2', '808-621-1570');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 2, 'GANDHI PALACE', 'Avenida da Rita 23', '908-379-7279');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 3, 'RESTAURANTE O ARCO', 'Arco do Cego 12', '479-738-0176');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 4, 'QUERMESSE', 'Rua Teodonio Pereira 27', '916-783-7861');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 5, 'DAPRATA52', 'Travessa Capitaes de Abril 12', '916-783-7861');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 6, 'FRANGASQUEIRA NACIONAL', 'Rua da Mesquita 2', '330-267-6646');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 1, 'ALFAMA CELLAR', 'Alameda D. Afonso Henriques 13', '248-551-7449');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 1, 'PISTOLA Y CORAZON', 'Rua da Prata 6', '831-293-5932');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 2, 'A CULTURA DO HAMBÚRGUER', 'Rua do Tecnico 7', '701-875-3461');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 5, 'PETISQUEIRA CONQVISTADOR', 'Avenida da Liberdade 22', '518-391-0296');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 7, 'A CEVICHERIA', 'Rua Maria de Lourdes Pintassilgo 12', '828-442-1023');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 11, 'RESTAURANTE BONJARDIM', 'Rua Pessoa 8', '651-760-2329');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 13, 'LISBOA CHEIA DE GRAÇA', 'Estrada dos Consquitadores 9', '231-760-9659');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 15, 'SOLAR 31', 'Rua da Universidade 9', '314-705-7957');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 17, 'BROOKLYN', 'Rua da Constanca 64', '740-275-8256');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 19, 'SANTA RITA', 'Rua da Esperanca 3', '518-391-0296');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 16, 'CHAPITÔ À MESA', 'Lugar do Bravo Rio 4', '415-771-2470');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 13, 'CHOUPANA CAFFE', 'Travessa dos Infortunios 11', '405-651-9588');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 12, 'MANTEIGARIA', 'Rua Primeiro de Maio 7', '404-928-8291');
INSERT INTO `dataretrieval`.`restaurant` (`restaurant_id`, `postal_code_id`, `restaurant_name`, `street_address`, `contact_number`) VALUES (DEFAULT, 1, 'VATICAN CAFFE', 'Alameda dos Oceanos 4', '203-891-7529');

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`order_type`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`order_type` (`order_type_id`, `order_type`) VALUES (DEFAULT, 'Delivery');
INSERT INTO `dataretrieval`.`order_type` (`order_type_id`, `order_type`) VALUES (DEFAULT, 'Eat-in');
INSERT INTO `dataretrieval`.`order_type` (`order_type_id`, `order_type`) VALUES (DEFAULT, 'Pickup');

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`payment_option`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`payment_option` (`payment_option_id`, `payment_option`) VALUES (DEFAULT, 'Cash');
INSERT INTO `dataretrieval`.`payment_option` (`payment_option_id`, `payment_option`) VALUES (DEFAULT, 'Card');
INSERT INTO `dataretrieval`.`payment_option` (`payment_option_id`, `payment_option`) VALUES (DEFAULT, 'Cheque');

COMMIT;

-- -----------------------------------------------------
-- Data for table `dataretrieval`.`job`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Director');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Executive Chef');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Head Chef');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Deputy Chef');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Station Chef');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Sauté Chef');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Boucher');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Poissonnier');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Rotisseur');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Friturier');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Grillardin');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Garde Manger');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Pattisier');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Chef de Tournant');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Entremetier');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Commis Chef');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Kitchen Porter');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Escuelerie');
INSERT INTO `dataretrieval`.`job` (`job_id`, `job_title`) VALUES (DEFAULT, 'Aboyeur');

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`driver`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Alistar', 'Crowley', '809-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Matej', 'Matic', '108-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'John', 'Smith', '818-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Jane', 'Smith', '208-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Maria', 'Maric', '218-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Marta', 'Baric', '238-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Dexter', 'Linsey', '258-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Lidia', 'Draber', '278-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Silvia', 'Smiler', '348-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Alberto', 'Italiana', '438-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Stuart', 'Jameson', '358-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Ivan', 'Horvat', '658-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Nuno', 'Hito', '678-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Peter', 'Murse', '788-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Nikola', 'Retco', '548-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Beatriz', 'Niheo', '478-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Kevin', 'Mirto', '098-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Marco', 'Polo', '038-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Ali', 'Muher', '768-621-1570');
INSERT INTO `dataretrieval`.`driver` (`driver_id`, `first_name`, `last_name`, `contact_number`) VALUES (DEFAULT, 'Petra', 'Malina', '678-621-1570');

COMMIT;




-- -----------------------------------------------------
-- Data for table `dataretrieval`.`bank_account`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506513475756797222');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506511681695156556');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506515539549695377');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506517838191883534');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506516255413999508');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506515731752459983');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506519597497163697');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506511424434443655');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506511685663144263');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506514268394515855');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506518443268972798');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506514843312217437');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506514471375859279');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506516158888963870');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506515527499316888');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506515793489385430');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506512769646751332');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506516934636461583');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506513332565643184');
INSERT INTO `dataretrieval`.`bank_account` (`bank_account_id`, `bank_account`) VALUES (DEFAULT, 'PT50003506513611789834977');
COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`delivery_company`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'Glovo', '123-621-1570', 'Lisbon', 'glovo@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`, `city`, `email`) VALUES (DEFAULT, 'Uber Eats' ,'221-621-1570', 'Guarda', 'ubereats@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'Bolt Eats', '542-621-1570', 'Funchal', 'bolteats@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'Pauza', '235-621-1570', 'Faro', 'pauza@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'DHL', '808-621-1570', 'Evora', 'dhl@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'CTT', '254-621-1570', 'Coimbra','ctt@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'Too Good to Go', '103-621-1570', 'Braganca','toogoodtogo@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'BLT', '905-621-1570', 'Braga','blt@gmail.com');
INSERT INTO `dataretrieval`.`delivery_company` (`delivery_company_id`, `name`, `contact_number`,`city`, `email`) VALUES (DEFAULT, 'MDM', '864-621-1570', 'Beja','mdm@gmail.com');
COMMIT;



-- -----------------------------------------------------
-- Data for table `dataretrieval`.`delivery_company_has_driver`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (1, 1);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (1, 2);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (1, 3);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (2, 1);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (2, 2);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (2, 3);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (2, 8);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (3, 2);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (3, 3);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (5, 12);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (7, 12);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (8, 13);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (9, 1);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (6, 7);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (5, 3);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (6, 1);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (4, 2);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (2, 6);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (3, 1);
INSERT INTO `dataretrieval`.`delivery_company_has_driver` (`delivery_company_id`, `driver_id`) VALUES (4, 7);

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`employee`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (278770762, 1, 1, 1, NULL, 'Zlatko', 'Horvat', '3513 Kerry Way', '718-885-4855', 1, 120000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (255731604, 2, 1, 2, 278770762, 'Bitrus', 'Aysu', '5036 Kildeer Drive', '334-636-9962', 5, 60000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (290101662, 3, 2, 3, 255731604, 'Colette', 'Zdenko', '4102 Everette Alley', '330-272-8524', 3, 80000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (247834343, 4, 3, 4, 255731604, 'Tiia', 'Samira', '2008 Grove Street', '620-396-9250', 2, 100000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (265109876, 5, 4, 5, 255731604, 'Cláudia', 'Elena', '2165 Duffy Street', '440-678-6604' ,4, 65000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (282805699, 6, 5, 1, 255731604, 'Herman', 'Monika', '3255 Melrose Street', '314-635-1430' , 6, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (282296751, 7, 6, 1, 255731604, 'Liselotte', 'Perikles', '1376 Shady Pines Drive', '817-523-1447', 7, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (267405138, 8, 1, 3, 255731604, 'Saif al-Din', 'Gwynn', '3599 Coal Road', '812-470-7879', 8, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (232105570, 9, 1, 7, 267405138, 'Hermagoras', 'Deep', '3644 Cost Avenue', '808-781-7746', 9, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (298611597, 10, 1, 5, 232105570, 'Errol', 'Eutychos', '4701 Diamond Street', '419-934-2231', 10, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (276752457, 11, 2, 1, 232105570, 'Jovian', 'Reshmi', '1864 Kooter Lane', '478-627-6542', 11, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (245617469, 12, 3, 2, 232105570, 'Sivan', 'Alexandre', '4711 Clousson Road', '215-469-6830', 12, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (212090801, 13, 3, 15, 232105570, 'Ilana', 'Arastoo', '3987 Rainy Day Drive', '502-225-7627', 13, 55000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (257965580, 14, 2, 13, 232105570, 'Desdemona', 'Elvira', '3489 Buffalo Creek Road', '484-880-4725', 14, 50000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (212628038, 15, 5, 12, 232105570, 'Mayme', 'Tahnee', '539 Memory Lane', '617-521-8149', 15, 45000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (251514900, 16, 7, 15, 298611597, 'Avelina', 'Emigdio', '3693 Rollins Road', '904-642-3911', 16, 45000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (267900635, 17, 15, 4, 251514900, 'Hande', 'Kaveri', '4805 Haven Lane', '910-773-9102', 17, 40000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (213260050, 18, 18, 7, 251514900, 'Heraclius', 'Elmira', '3956 Prudence Street', '281-323-8093', 18, 35000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (250752689, 19, 12, 6, 251514900, 'Sjaak', 'Tayla', '4413 Circle Drive', '541-620-3597', 19, 30000);
INSERT INTO `dataretrieval`.`employee` (`employee_taxpayer_id`, `bank_account_id`, `restaurant_id`, `postal_code_id`, `superior_id`, `first_name`, `last_name`, `street_address`, `contact_number`, `job_id`, `salary`) VALUES (244952779, 20, 13, 8, 251514900, 'Manola', 'Geoffroy', '1208 Pride Avenue', '240-402-3959', 19, 30000);

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`allergen`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'peanut');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'lactose');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'eggs');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'fish');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'sesame');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'shellfish');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'soy');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'wheat');
INSERT INTO `dataretrieval`.`allergen` (`allergen_id`, `name`) VALUES (DEFAULT, 'nuts');

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`measurement`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`measurement` (`measurement_id`, `measurement`) VALUES (DEFAULT, 'kilograms');
INSERT INTO `dataretrieval`.`measurement` (`measurement_id`, `measurement`) VALUES (DEFAULT, 'liters');
INSERT INTO `dataretrieval`.`measurement` (`measurement_id`, `measurement`) VALUES (DEFAULT, 'items');
INSERT INTO `dataretrieval`.`measurement` (`measurement_id`, `measurement`) VALUES (DEFAULT, 'ounces');
INSERT INTO `dataretrieval`.`measurement` (`measurement_id`, `measurement`) VALUES (DEFAULT, 'pounds');
INSERT INTO `dataretrieval`.`measurement` (`measurement_id`, `measurement`) VALUES (DEFAULT, 'grams');

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`ingredient`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 1, 1, 'peanut', 12);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 1, 1, 'pepper', 20);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 5, 3, 'bread', 32);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 7, 1, 'cake', 123);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 6, 6, 'codfish', 150);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'soy', 12);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'pork', 15);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'beef', 125);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'chicken', 20);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 2, 2, 'butter', 65);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, 2, 6, 'milk', 500);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 2, 'oil', 12);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'grape', 5);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'peach', 22);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'apple', 12);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'oragne', 3);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'pickel', 5);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'onion', 7);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 1, 'ginger', 1);
INSERT INTO `dataretrieval`.`ingredient` (`ingredient_id`, `allergen_id`, `measurement_id`, `name`, `quantity`) VALUES (DEFAULT, NULL, 6, 'parsley', 120);

COMMIT;




-- -----------------------------------------------------
-- Data for table `dataretrieval`.`shift`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-01-18', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2019-01-23', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-24', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-03-18', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-22', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-12', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-18', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-11', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-13', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-14', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-15', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-16', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-17', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-18', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-02-19', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-07-18', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-07-18', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-07-19', 0);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-07-20', 1);
INSERT INTO `dataretrieval`.`shift` (`shift_id`, `shift_date`, `morning`) VALUES (DEFAULT, '2018-07-21', 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`employee_has_shift`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (1, 278770762, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (1, 290101662, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (1, 212090801, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (1, 257965580, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (2, 245617469, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (3, 276752457, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (4, 298611597, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (4, 232105570, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (2, 282296751, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (6, 267405138, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (6, 282805699, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (4, 265109876, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (12, 212090801, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (3, 257965580, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (3, 212628038, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (2, 251514900, 0);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (7, 267900635, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (18, 213260050, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (17, 250752689, 1);
INSERT INTO `dataretrieval`.`employee_has_shift` (`shift_id`, `employee_taxpayer_id`, `manager`) VALUES (16, 244952779, 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`price` 
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 6);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 8);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 10);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 12);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 14);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 11);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 16);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 15);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 21);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 17);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 20);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 5);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 28);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 19);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 22);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 18);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 23);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 29);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 24);
INSERT INTO `dataretrieval`.`price` (`price_id`, `base_price`) VALUES (DEFAULT, 35);


COMMIT;

-- -----------------------------------------------------
-- Data for table `dataretrieval`.`size` 
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`size` (`size_id`, `size`) VALUES (DEFAULT, 'Small');
INSERT INTO `dataretrieval`.`size` (`size_id`, `size`) VALUES (DEFAULT, 'Medium');
INSERT INTO `dataretrieval`.`size` (`size_id`, `size`) VALUES (DEFAULT, 'Large');
INSERT INTO `dataretrieval`.`size` (`size_id`, `size`) VALUES (DEFAULT, 'Extra Large');

COMMIT;



COMMIT;

-- -----------------------------------------------------
-- Data for table `dataretrieval`.`price_modifier` 
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 1);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 1.5);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 1.9);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.5);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.95);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.90);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.85);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.80);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.75);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.70);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.65);
INSERT INTO `dataretrieval`.`price_modifier` (`price_modifier_id`, `price_modifier`) VALUES (DEFAULT, 0.60);

COMMIT;


-- -----------------------------------------------------
-- Data for table `dataretrieval`.`order`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 3, 3, 1, 654367807, 276752457, '2019-04-05 18:30:00', 0, 'Allergic to peanuts', NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 4, 2, NULL, 212246218, 276752457,'2019-04-06 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 5, 1, NULL, 793134894, 276752457,'2020-04-07 18:30:00', 0, NULL, 3);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 2, 3, NULL, 833799495, 276752457,'2018-04-08 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 6, 2, NULL, 806952487, 244952779,'2015-04-09 18:30:00', 0, NULL, 1);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 7, 1, NULL, 654367807, 276752457,'2018-04-10 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 8, 1, NULL, 833799495, 276752457,'2020-04-15 18:30:00', 0, NULL, 1);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 3, 1, 1, 2, 793134894, 250752689, '2019-04-14 18:30:00', 0, 'Allergic to milk', NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 3, 2, 1, 3, 399220897, 250752689,'2012-04-13 18:30:00', 0, NULL, 5);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 3, 9, 2, 4, 654367807, 250752689, '2018-04-12 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 3, 8, 3, 5, 942604591, 250752689, '2018-04-11 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 6, 2, 6, 806952487, 244952779, '2019-04-16 18:30:00', 0, NULL, 3);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 2, 2, 1, 346777180, 244952779, '2013-04-17 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 1, 3, 2, 654367807, 244952779, '2016-04-18 18:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 3, 3, 2, 3, 212246218, 244952779, '2013-04-19 18:30:00', 0, NULL, 5);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 1, 1, 2, 833799495, 244952779, '2014-04-20 18:30:00', 0, 'Allergic to butter', NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 3, 3, 1, 5, 212246218, 244952779, '2021-04-20 17:30:00', 0, NULL, 2);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 2, 4, 1, NULL, 308309888, 276752457,'2021-04-20 16:30:00', 0, NULL, NULL);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 5, 3, 1, 308309888, 244952779, '2021-04-20 13:30:00', 0, NULL, 2);
INSERT INTO `dataretrieval`.`order` (`order_id`, `order_type_id`, `restaurant_id`, `payment_option_id`, `delivery_company_id`, `customer_taxpayer_id`, `employee_taxpayer_id`,`date`,`total_price`, `order_comment`, `rating`) VALUES (DEFAULT, 1, 6, 2, 1, 793134894, 244952779, '2020-04-25 18:30:00', 0, NULL, NULL);

COMMIT;




-- -----------------------------------------------------
-- Data for table `dataretrieval`.`item`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 1, 1, 1, 1, 'Hawai', 4);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 1, 2, 1, 1, 'Meat', 2);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 2, 3, 1, 1, 'Cheese', 3);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 3, 4, 2, 2, 'Veggie', 1);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 11, 5, 3, 3, 'Pepperoni', 2);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 12, 6, 4, 4, 'Margherita', 6);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 15, 7, 3, 2, 'Capricciosa', 12);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 17, 8, 1, 1, 'BBQ Chicken', 25);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 2, 9, 1, 1, 'Mexican', 31);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 2, 10, 4, 3, 'Shrimp', 5);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 3, 9, 3, 3, 'Mexican', 6);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 3, 9, 3, 2, 'Mexican', 3);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 6, 11, 2, 2, 'Supreme', 6);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 8, 1, 3, 3, 'Hawai', 22);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 9, 1, 3, 3, 'Carbonara', 10);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 7, 12, 3, 4, 'Montanara', 3);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 19, 1, 1, 1, 'Hawai', 5);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 6, 8, 4, 4, 'Americana', 6);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 5, 3, 4, 3, 'Gorgonzola', 7);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 3, 13, 3, 2, 'Mediterranea', 2);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 4, 10, 4, 3, 'Shrimp', 3);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 10, 9, 2, 3, 'Mexican', 2);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 13, 9, 1, 2, 'Mexican', 5);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 14, 11, 2, 2, 'Supreme', 4);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 16, 1, 3, 3, 'Hawai', 12);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 18, 1, 5, 3, 'Carbonara', 11);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 19, 12, 3, 4, 'Montanara', 13);
INSERT INTO `dataretrieval`.`item` (`item_id`,  `order_id`, `price_id`, `price_modifier_id`, `size_id`, `name`, `units`) VALUES (DEFAULT, 20, 1, 1, 1, 'Hawai', 7);


COMMIT;



-- -----------------------------------------------------
-- Data for table `dataretrieval`.`item_has_ingredient`
-- -----------------------------------------------------
START TRANSACTION;
USE `dataretrieval`;
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (1, 1);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (2, 1);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (3, 1);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (4, 1);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (15, 2);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (16, 2);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (17, 2);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (3, 2);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (15, 9);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (13, 9);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (5, 9);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (7, 9);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (11, 11);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (15, 11);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (3, 11);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (5, 11);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (6, 11);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (6, 13);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (3, 13);
INSERT INTO `dataretrieval`.`item_has_ingredient` (`ingredient_id`, `item_id`) VALUES (2, 13);

COMMIT;

USE `dataretrieval`;


-- -----------------------------------------------------
-- -------------------VIEW RECEIPT----------------------
-- -----------------------------------------------------
-- View contains item names, and all columns necessary for calculating price of each item
-- -----------------------------------------------------


CREATE VIEW reciept AS 
SELECT i.`name` AS 'Description', p.base_price AS 'Base Price', i.units AS 'Quantity', CONCAT(ROUND((1 - pm.price_modifier)* 100), '%') AS Discount, ROUND(((p.base_price * pm.price_modifier) * i.units),2) AS 'Amount'
FROM item i
	INNER JOIN `order` o
    ON o.order_id = i.order_id
    INNER JOIN price p
    ON p.price_id = i.price_id
    INNER JOIN order_type ot
    ON ot.order_type_id = o.order_type_id
	INNER JOIN restaurant r
    ON o.restaurant_id = r.restaurant_id
	INNER JOIN customer c
    ON c.customer_taxpayer_id = o.customer_taxpayer_id
    INNER JOIN price_modifier pm
    ON pm.price_modifier_id = i.price_modifier_id
    WHERE o.order_id = 2;
    

    

-- -----------------------------------------------------
-- --------------------VIEW HEADER----------------------
-- -----------------------------------------------------
-- View header contains information about the restaurant and the customer and its order that would be redundant in the reciept
-- That means everything that would be repeated more then once is put into header and not into receipt
-- -----------------------------------------------------


CREATE VIEW header AS
SELECT o.order_id as 'Order ID', r.restaurant_name AS 'Restaurant Name', pc.city AS 'City', r.contact_number AS 'Contact Number', c.customer_taxpayer_id AS 'Customer ID', c.first_name AS 'First Name', c.last_name AS 'Last Name', c.street_address AS 'Street Address', ot.order_type AS 'Order type', o.order_comment AS 'Order Comment', o.`date` AS 'Date', o.total_price AS 'Total Price'
FROM restaurant r
	INNER JOIN `order` o
    ON r.restaurant_id = o.restaurant_id
	INNER JOIN customer c
    ON c.customer_taxpayer_id = o.customer_taxpayer_id
    INNER JOIN postal_code pc
    ON pc.postal_code_id = r.postal_code_id
    INNER JOIN order_type ot
    ON ot.order_type_id = o.order_type_id
    WHERE o.order_id = 2;




