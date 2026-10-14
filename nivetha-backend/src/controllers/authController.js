const Owner = require("../models/Owner");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.login = async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        message: "Phone number and password are required",
      });
    }

    // passwordHash has select: false in Owner model
    const owner = await Owner.findOne({ phone }).select("+passwordHash");

    if (!owner) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password",
      });
    }

    if (!owner.isActive) {
      return res.status(403).json({
        success: false,
        message: "Owner account is inactive",
      });
    }

    // Prevent bcrypt undefined error
    if (!owner.passwordHash) {
      console.error("Owner passwordHash is missing in database");

      return res.status(500).json({
        success: false,
        message: "Owner password is not configured. Reset the owner password.",
      });
    }

    const isMatch = await bcrypt.compare(
      password,
      owner.passwordHash
    );

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password",
      });
    }

    if (!process.env.JWT_SECRET) {
      return res.status(500).json({
        success: false,
        message: "JWT_SECRET is missing in .env",
      });
    }

    const token = jwt.sign(
      { id: owner._id.toString(), role: "owner" },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    return res.status(200).json({
      success: true,
      message: "Owner login successful",
      token,
      user: {
        id: owner._id,
        name: owner.name,
        phone: owner.phone,
        role: "owner",
      },
    });
  } catch (error) {
    console.error("Owner login error:", error);

    return res.status(500).json({
      success: false,
      message: "Owner login failed",
    });
  }
};

exports.getMe = async (req, res) => {
  try {
    const owner = await Owner.findById(req.user.id);
    if (!owner || !owner.isActive) {
      return res.status(404).json({
        success: false,
        message: "Owner account not found or inactive",
      });
    }

    const profile = {
      id: owner._id,
      name: owner.name,
      phone: owner.phone,
      role: "owner",
    };
    return res.status(200).json({ success: true, owner: profile, user: profile });
  } catch (error) {
    console.error("Owner profile error:", error);
    return res.status(500).json({
      success: false,
      message: "Unable to load owner profile",
    });
  }
};
