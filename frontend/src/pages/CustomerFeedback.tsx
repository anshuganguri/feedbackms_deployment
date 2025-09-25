import React, { useState, useEffect } from 'react';
import Header from '../components/Header';
import StarRating from '../components/StarRating';
import { useToast } from '../contexts/ToastContext';
import { useAuth } from '../contexts/AuthContext';
import { Plus, Edit, Trash2, MessageSquare } from 'lucide-react';
import axios from 'axios';

interface Feedback {
  id: string;
  rating: number;
  comment: string;
  service: string;
  timestamp: string;
  userId: string;
}

const SERVICES = [
  'Swiggy',
  'Zomato',
  'SBI',
  'ICICI',
  'HDFC',
  'Amazon',
  'Flipkart',
  'Netflix',
];

const API_URL = 'http://localhost:8090/feedback_management'; // 👈 adjust to your Spring Boot backend

const CustomerFeedback: React.FC = () => {
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingFeedback, setEditingFeedback] = useState<Feedback | null>(null);
  const [formData, setFormData] = useState({
    rating: 0,
    comment: '',
    service: '',
  });

  const { showToast } = useToast();
  const { user } = useAuth();

  // Load feedbacks from backend
  useEffect(() => {
    if (!user) return;
    axios
      .get<Feedback[]>(`${API_URL}/customer-feedback`)
      .then((res) => setFeedbacks(res.data))
      .catch(() => showToast('Failed to load feedbacks', 'error'));
  }, [user]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (formData.rating === 0) {
      showToast('Please select a rating', 'error');
      return;
    }

    try {
      if (editingFeedback) {
        // Update existing feedback
        const res = await axios.put<Feedback>(
          `${API_URL}/${editingFeedback.id}`,
          { ...formData, userId: user?.id }
        );
        setFeedbacks(
          feedbacks.map((f) => (f.id === editingFeedback.id ? res.data : f))
        );
        showToast('Feedback updated successfully!', 'success');
      } else {
        // Create new feedback
        const res = await axios.post<Feedback>(API_URL, {
          ...formData,
          userId: user?.id,
        });
        setFeedbacks([...feedbacks, res.data]);
        showToast('Feedback submitted successfully!', 'success');
      }

      setFormData({ rating: 0, comment: '', service: '' });
      setShowForm(false);
      setEditingFeedback(null);
    } catch {
      showToast('Failed to save feedback', 'error');
    }
  };

  const handleEdit = (feedback: Feedback) => {
    setEditingFeedback(feedback);
    setFormData({
      rating: feedback.rating,
      comment: feedback.comment,
      service: feedback.service,
    });
    setShowForm(true);
  };

  const handleDelete = async (id: string) => {
    try {
      await axios.delete(`${API_URL}/${id}`);
      setFeedbacks(feedbacks.filter((f) => f.id !== id));
      showToast('Feedback deleted successfully!', 'success');
    } catch {
      showToast('Failed to delete feedback', 'error');
    }
  };

  const resetForm = () => {
    setFormData({ rating: 0, comment: '', service: '' });
    setShowForm(false);
    setEditingFeedback(null);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />

      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold text-gray-900">My Feedback</h1>
          <button
            onClick={() => setShowForm(true)}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 transition-colors"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add Feedback
          </button>
        </div>

        {/* Form */}
        {showForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <h3 className="text-lg font-medium mb-4">
                {editingFeedback ? 'Edit Feedback' : 'Add New Feedback'}
              </h3>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Service/Product
                  </label>
                  <select
                    value={formData.service}
                    onChange={(e) =>
                      setFormData({ ...formData, service: e.target.value })
                    }
                    required
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Select a service</option>
                    {SERVICES.map((service) => (
                      <option key={service} value={service}>
                        {service}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Rating
                  </label>
                  <StarRating
                    rating={formData.rating}
                    onRatingChange={(rating) =>
                      setFormData({ ...formData, rating })
                    }
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Comment
                  </label>
                  <textarea
                    value={formData.comment}
                    onChange={(e) =>
                      setFormData({ ...formData, comment: e.target.value })
                    }
                    required
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Share your experience..."
                  />
                </div>

                <div className="flex space-x-3 pt-4">
                  <button
                    type="submit"
                    className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors"
                  >
                    {editingFeedback ? 'Update' : 'Submit'}
                  </button>
                  <button
                    type="button"
                    onClick={resetForm}
                    className="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-md hover:bg-gray-400 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Feedback list */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {feedbacks.length === 0 ? (
            <div className="col-span-full text-center py-12">
              <MessageSquare className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                No feedback yet
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                Get started by adding your first feedback.
              </p>
            </div>
          ) : (
            feedbacks.map((feedback) => (
              <div
                key={feedback.id}
                className="bg-white overflow-hidden shadow rounded-lg"
              >
                <div className="p-6">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-medium text-gray-900">
                      {feedback.service}
                    </h3>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => handleEdit(feedback)}
                        className="text-blue-600 hover:text-blue-800"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDelete(feedback.id)}
                        className="text-red-600 hover:text-red-800"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>

                  <div className="mb-3">
                    <StarRating rating={feedback.rating} readonly />
                  </div>

                  <p className="text-gray-600 text-sm mb-4">
                    {feedback.comment}
                  </p>

                  <p className="text-xs text-gray-500">
                    {new Date(feedback.timestamp).toLocaleDateString()}
                  </p>
                </div>
              </div>
            ))
          )}
        </div>
      </main>
    </div>
  );
};

export default CustomerFeedback;
