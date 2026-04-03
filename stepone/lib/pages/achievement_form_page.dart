import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achievement.dart';
import '../models/category.dart';
import '../services/achievement_dao.dart';
import '../services/category_dao.dart';
import '../theme/app_theme.dart';

class AchievementFormPage extends StatefulWidget {
  final Achievement? achievement;

  const AchievementFormPage({super.key, this.achievement});

  @override
  State<AchievementFormPage> createState() => _AchievementFormPageState();
}

class _AchievementFormPageState extends State<AchievementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AchievementDao _achievementDao = AchievementDao();
  final CategoryDao _categoryDao = CategoryDao();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _organizationController;
  late TextEditingController _certificateNumberController;
  late TextEditingController _remarksController;
  
  List<Category> _categories = [];
  Category? _selectedCategory;
  String _achievementType = 'award';
  DateTime _achievementDate = DateTime.now();
  String? _awardLevel;
  bool _isCollective = false;
  bool _isLeader = false;
  int? _participantCount;
  
  bool _isLoading = true;
  bool get _isEditing => widget.achievement != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.achievement?.title ?? '');
    _descriptionController = TextEditingController(text: widget.achievement?.description ?? '');
    _organizationController = TextEditingController(text: widget.achievement?.organization ?? '');
    _certificateNumberController = TextEditingController(text: widget.achievement?.certificateNumber ?? '');
    _remarksController = TextEditingController(text: widget.achievement?.remarks ?? '');
    
    if (widget.achievement != null) {
      _achievementType = widget.achievement!.achievementType;
      _achievementDate = widget.achievement!.achievementDate;
      _awardLevel = widget.achievement!.awardLevel;
      _isCollective = widget.achievement!.isCollective;
      _isLeader = widget.achievement!.isLeader;
      _participantCount = widget.achievement!.participantCount;
    }
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryDao.getAll();
    setState(() {
      _categories = categories;
      if (widget.achievement != null) {
        _selectedCategory = categories.firstWhere(
          (c) => c.id == widget.achievement!.categoryId,
          orElse: () => categories.first,
        );
      } else if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizationController.dispose();
    _certificateNumberController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveAchievement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择成就分类')),
      );
      return;
    }

    final now = DateTime.now();
    final achievement = Achievement(
      id: widget.achievement?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id!,
      achievementType: _achievementType,
      achievementDate: _achievementDate,
      awardLevel: _awardLevel,
      organization: _organizationController.text.trim().isEmpty 
          ? null 
          : _organizationController.text.trim(),
      certificateNumber: _certificateNumberController.text.trim().isEmpty 
          ? null 
          : _certificateNumberController.text.trim(),
      isCollective: _isCollective,
      isLeader: _isLeader,
      participantCount: _participantCount,
      remarks: _remarksController.text.trim().isEmpty 
          ? null 
          : _remarksController.text.trim(),
      createdAt: widget.achievement?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await _achievementDao.update(achievement);
      } else {
        await _achievementDao.insert(achievement);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '成就已更新' : '成就已创建'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _achievementDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _achievementDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑成就' : '新建成就'),
        actions: [
          TextButton(
            onPressed: _saveAchievement,
            child: const Text('保存'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('基本信息'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '成就名称 *',
                      hintText: '例如：全国大学生数学建模竞赛一等奖',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入成就名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '详细描述',
                      hintText: '描述这个成就的详细信息',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: '成就分类 *',
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return '请选择成就分类';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _achievementType,
                    decoration: const InputDecoration(
                      labelText: '成就类型',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'award', child: Text('获奖')),
                      DropdownMenuItem(value: 'patent', child: Text('专利')),
                      DropdownMenuItem(value: 'project', child: Text('项目')),
                      DropdownMenuItem(value: 'paper', child: Text('论文')),
                      DropdownMenuItem(value: 'certificate', child: Text('证书')),
                      DropdownMenuItem(value: 'practice', child: Text('实践')),
                    ],
                    onChanged: (value) {
                      setState(() => _achievementType = value ?? 'award');
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('时间和组织'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '获得日期',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy年MM月dd日').format(_achievementDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _organizationController,
                    decoration: const InputDecoration(
                      labelText: '颁发组织',
                      hintText: '例如：教育部',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _awardLevel,
                    decoration: const InputDecoration(
                      labelText: '获奖等级',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'national', child: Text('国家级')),
                      DropdownMenuItem(value: 'provincial', child: Text('省级')),
                      DropdownMenuItem(value: 'city', child: Text('市级')),
                      DropdownMenuItem(value: 'school', child: Text('校级')),
                    ],
                    onChanged: (value) {
                      setState(() => _awardLevel = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('团队信息'),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('团队成就'),
                    subtitle: const Text('是否为团队共同获得的成就'),
                    value: _isCollective,
                    onChanged: (value) {
                      setState(() => _isCollective = value);
                    },
                  ),
                  if (_isCollective) ...[
                    SwitchListTile(
                      title: const Text('我是负责人'),
                      value: _isLeader,
                      onChanged: (value) {
                        setState(() => _isLeader = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _participantCount?.toString(),
                      decoration: const InputDecoration(
                        labelText: '参与人数',
                        hintText: '输入团队总人数',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _participantCount = int.tryParse(value);
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('其他信息'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _certificateNumberController,
                    decoration: const InputDecoration(
                      labelText: '证书编号',
                      hintText: '如有证书编号可填写',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      hintText: '其他需要说明的信息',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
