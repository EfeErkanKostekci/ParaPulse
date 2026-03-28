// TODO: Authentication logic (Register, Login, vs.) Hafta 2 kapsamında buraya eklenecektir.

const register = async (req, res) => {
  res.status(501).json({ message: 'Register henüz uygulanmadı' });
};

const login = async (req, res) => {
  res.status(501).json({ message: 'Login henüz uygulanmadı' });
};

module.exports = {
  register,
  login
};
