const userService = require("../services/customerService");

const searchCustomers = async (req, res, next) => {
  try {
    const customers = await userService.searchCustomers(req.query.query);
    res.json({ customers });
  } catch (error) {
    next(error);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const user = await userService.updateProfile(req.user._id, req.body);
    res.json({ user });
  } catch (error) {
    next(error);
  }
};

const checkPhoneAvailable = async (req, res, next) => {
  try {
    const result = await userService.checkPhoneAvailable(
      req.user._id,
      req.query.phone
    );
    res.json(result);
  } catch (error) {
    next(error);
  }
};

const updateAvatar = async (req, res, next) => {
  try {
    const user = await userService.updateAvatar(req.user._id, req.file);
    res.json({ user });
  } catch (error) {
    next(error);
  }
};

const removeAvatar = async (req, res, next) => {
  try {
    const user = await userService.removeAvatar(req.user._id);
    res.json({ user });
  } catch (error) {
    next(error);
  }
};

const redeemCustomerPoints = async (req, res, next) => {
  try {
    const result = await userService.redeemCustomerPoints({
      customerId: req.params.customerId,
      manager: req.user,
      note: req.body.note,
      points: req.body.points,
      rewardName: req.body.rewardName,
    });
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  checkPhoneAvailable,
  removeAvatar,
  updateAvatar,
  redeemCustomerPoints,
  searchCustomers,
  updateProfile,
};
