// TODO: Transaction CRUD logic (Create, Read, Update, Delete) Hafta 2 kapsamında buraya eklenecektir.

const getTransactions = async (req, res) => {
  res.status(501).json({ message: 'getTransactions henüz uygulanmadı' });
};

module.exports = {
  getTransactions
};
